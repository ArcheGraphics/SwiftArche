//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit
import Metal
import Logging

public let logger = Logger(label: "com.arche.main")

public extension CodingUserInfoKey {
    static var polymorphicTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.polymophicTypes")!
    }
    static var colliderShapeTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "com.codable.colliderShapeTypes")!
    }
}

public class Engine: NSObject {
    // The max number of command buffers in flight
    static let _maxFramesInFlight = 3
    static var _bufferPools: [BufferPool] = []
    static var _commandQueue: MTLCommandQueue!
    static let _macroCollection: ShaderMacroCollection = ShaderMacroCollection()
    static let _componentsManager: ComponentsManager = ComponentsManager()
    static let _lightManager = LightManager()
    
    private let _inFlightSemaphore: DispatchSemaphore
    private var _frameCount: Int = 0
    
    // Current buffer index to fill with dynamic uniform data and set for the current frame
    private static var _currentBufferIndex: Int = 0
    private static var _resourceCache: ResourceCache!
    private static var _library: [String: MTLLibrary] = [:]
    private static var _settings: EngineSettings? = nil
    private static var _device: MTLDevice!
    private static var _sceneManager: SceneManager!
    private static var _physicsManager: PhysicsManager!
    private static var _inputManager: InputManager!
#if os(iOS)
    private static var _arManager: ARManager?
#else
    static var _guiManager: GUIManager!
#endif
    // The semaphore used to control GPU-CPU synchronization of frames.
    private static var _textureLoader: TextureLoader!
    private static var _isPaused: Bool = true;
    private static let _fg = FrameGraph()

    /// buffer index
    static var currentBufferIndex: Int {
        get {
            _currentBufferIndex
        }
    }
    
    static var resourceCache: ResourceCache {
        get {
            _resourceCache
        }
    }
    
    static var fg: FrameGraph {
        get {
            _fg
        }
    }
    
    public static var exportGraphviz: Bool = false
    
    // MARK: - Public Method
    /// canvas
    public static var canvas: Canvas!

    /// Settings of Engine.
    public static var settings: EngineSettings? {
        get {
            _settings
        }
    }

    /// Get the Metal device.
    public static var device: MTLDevice {
        get {
            _device
        }
    }
    
    public static var commandQueue: MTLCommandQueue {
        get {
            _commandQueue
        }
    }

    /// Get the texture loader.
    public static var textureLoader: TextureLoader {
        get {
            _textureLoader
        }
    }

    /// Get the scene manager.
    public static var sceneManager: SceneManager {
        get {
            _sceneManager
        }
    }

    /// Get the physics manager.
    public static var physicsManager: PhysicsManager {
        get {
            _physicsManager
        }
    }

    /// Get the input manager.
    public static var inputManager: InputManager {
        get {
            _inputManager
        }
    }

#if os(iOS)
    /// Get the ar manager.
    public static var arManager: ARManager? {
        get {
            _arManager
        }
    }
#endif

    /// Whether the engine is paused.
    public static var isPaused: Bool {
        get {
            _isPaused
        }
        set {
            _isPaused = newValue
            if !newValue {
                Time.reset()
            }
        }
    }

    public init(canvas: Canvas) {
        Engine.canvas = canvas
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        Engine._device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to create default Metal Device")
        }
        Engine._commandQueue = commandQueue
        _inFlightSemaphore = DispatchSemaphore(value: Engine._maxFramesInFlight)
        Engine._bufferPools = [BufferPool](repeating: BufferPool(Engine._device, 256), count: Engine._maxFramesInFlight)
        Engine._resourceCache = ResourceCache(device)
        
        super.init()
        _ = Engine.createShaderLibrary("vox.shader")
        Engine._physicsManager = PhysicsManager()
        Engine._inputManager = InputManager()
        Engine._sceneManager = SceneManager()
        let scene = Scene()
        scene.name = "DefaultScene"
        Engine._sceneManager.activeScene = scene
        canvas.delegate = self
        canvas.device = device
        canvas.inputManager = Engine._inputManager
        Engine._textureLoader = TextureLoader()

#if os(macOS)
        Engine._guiManager = GUIManager()
#endif
    }

#if os(iOS)
    public static func initArSession() {
        _arManager = ARManager(device)
        let scene = _sceneManager.activeScene!
        scene.background.mode = .AR
        scene.background.ar = ARSubpass()
    }
#endif
    
    public static func createCaptureScope(name: String) -> MTLCaptureScope {
        let scope = MTLCaptureManager.shared().makeCaptureScope(device: device)
        scope.label = name
        let captureDescriptor = MTLCaptureDescriptor()
        captureDescriptor.captureObject = scope
        captureDescriptor.destination = .developerTools
        do {
            try MTLCaptureManager.shared().startCapture(with: captureDescriptor)
        } catch let error {
            fatalError("Error creating capture scope \(name), error \(error)")
        }
        return scope
    }
    
    public static func createShaderLibrary(_ name: String) -> MTLLibrary {
        // Load all the shader files with a metal file extension in the project
        let libraryURL = Bundle.main.url(forResource: name, withExtension: "metallib")!
        do {
            let library = try device.makeLibrary(URL: libraryURL)
            _library[name] = library
            return library
        } catch let error {
            fatalError("Error creating metal library \(name), error \(error)")
        }
    }
    
    public static func library(_ name: String = "vox.shader") -> MTLLibrary {
        if let library = _library[name] {
            return library
        } else {
            return createShaderLibrary(name)
        }
    }
    
    public static func requestBufferBlock(minimum_size: Int) -> BufferBlock {
        _bufferPools[_currentBufferIndex].requestBufferBlock(minimum_size: minimum_size)
    }
    
    /// Execution engine loop.
    public static func run() {
        isPaused = false
    }
    
    public static func destroy() {
        sceneManager.destroy()
        physicsManager.destroy()
#if os(macOS)
        _guiManager.destroy()
#endif
    }
    
    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        let scriptClass = ClassInfo.getSubclass(Script.self)
        var componentList: [Polymorphic.Type] = [
            Transform.self,
            Camera.self,
            Light.self,
            StaticCollider.self,
            DynamicCollider.self,
            FixedJoint.self
        ]
        componentList.append(contentsOf: scriptClass.map { info in
            info.classObject as! Polymorphic.Type
        })
        decoder.userInfo[.polymorphicTypes] = componentList
        decoder.userInfo[.colliderShapeTypes] = [
            SphereColliderShape.self,
            CapsuleColliderShape.self,
            BoxColliderShape.self,
            PlaneColliderShape.self
        ]

        return decoder
    }
}

// MARK: - Main Loop
extension Engine: MTKViewDelegate {
    /// Update the engine loop manually. If you call Engine.run(), you generally don't need to call this function.
    func update() {
        Time.tick();
        let deltaTime = Time.deltaTime;

        if !Engine._isPaused {
            // Wait to ensure only maxFramesInFlight are getting processed by any stage in the Metal
            //   pipeline (App, Metal, Drivers, GPU, etc)
            _inFlightSemaphore.wait()
            Engine._currentBufferIndex = (Engine._currentBufferIndex + 1) % Engine._maxFramesInFlight
            Engine._bufferPools[Engine._currentBufferIndex].reset()
            
            let scene = Engine._sceneManager._activeScene
            let componentsManager = Engine._componentsManager
            if (scene != nil) {
                scene!._activeCameras.sort { camera1, camera2 in
                    camera1.priority > camera2.priority
                }

                componentsManager.callScriptOnStart()
                Engine._physicsManager._update(deltaTime)
                Engine._inputManager._update()
                componentsManager.callScriptOnUpdate(deltaTime)
                componentsManager.callAnimationUpdate(deltaTime)
                componentsManager.callScriptOnLateUpdate(deltaTime)
                _render(scene!)
            }
            componentsManager.handlingInvalidScripts()
        }
    }

    func _render(_ scene: Scene) {
#if os(iOS)
        Engine.arManager?.update(Time.deltaTime)
#endif
        Engine._componentsManager.callRendererOnUpdate(Time.deltaTime)

        scene._updateShaderData()

        let cameras = scene._activeCameras
        if (cameras.count > 0) {
            if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
               let currentDrawable = Engine.canvas.currentDrawable,
               let renderPassDescriptor = Engine.canvas.currentRenderPassDescriptor,
               let colorTexture = renderPassDescriptor.colorAttachments[0].texture,
               let depthTexture = renderPassDescriptor.depthAttachment.texture {
                // Add completion hander which signals inFlightSemaphore
                // when Metal and the GPU has fully finished processing the commands encoded for this frame.
                // This indicates when the dynamic buffers, written this frame, will no longer be needed by Metal and the GPU.
                commandBuffer.addCompletedHandler { [weak self] _ in
                    self?._inFlightSemaphore.signal()
                }
                
                let fg = Engine._fg
                fg.blackboard[BlackBoardType.color.rawValue]
                = fg.addRetainedResource(for: MTLTextureDescriptor.self, name: "colorTexture",
                                         description: MTLTextureDescriptor(), actual: colorTexture)
                fg.blackboard[BlackBoardType.depth.rawValue]
                = fg.addRetainedResource(for: MTLTextureDescriptor.self, name: "depthTexture",
                                         description: MTLTextureDescriptor(), actual: depthTexture)
                
                for camera in cameras {
                    camera.update()
                    Engine._componentsManager.callCameraOnBeginRender(camera, commandBuffer)
                    camera.devicePipeline.commit(with: commandBuffer)
                    Engine._componentsManager.callCameraOnEndRender(camera, commandBuffer)
                }
                scene.postprocess(commandBuffer)
                Engine._guiManager.draw(commandBuffer)

                fg.compile()
                fg.execute()
                if Engine.exportGraphviz {
                    fg.exportGraphviz(filename: "pipeline")
                    Engine.exportGraphviz = false
                }
                fg.clear()


                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
            }
        } else {
            logger.debug("NO active camera.")
        }
        
        _frameCount += 1
        if _frameCount > 50 {
            garbageCollection()
            _frameCount = 0
        }
    }
    
    func garbageCollection() {
        Engine.resourceCache.garbageCollection(below: 10)
    }
    
    /// Called whenever the drawableSize of the view will change
    /// - Remark: Delegate can recompute view and projection matrices or regenerate any buffers
    /// to be compatible with the new view size or resolution
    /// - Parameters:
    ///   - view: MTKView which called this method
    ///   - size: New drawable size in pixels
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        Engine.canvas.dispatchResize(size)
    }

    /// Called on the delegate when it is asked to render into the view
    /// - Remark: Called on the delegate when it is asked to render into the view
    /// - Parameter view:  MTKView which called this method
    public func draw(in view: MTKView) {
        update()
    }
}
