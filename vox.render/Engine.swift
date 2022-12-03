//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit
import Metal
import Logging

let logger = Logger(label: "com.arche.main")

public class Engine: NSObject {
    public let canvas: Canvas
    let _commandQueue: MTLCommandQueue
    let _macroCollection: ShaderMacroCollection = ShaderMacroCollection()
    let _componentsManager: ComponentsManager = ComponentsManager()
    let _lightManager = LightManager()

    private var _library: [String: MTLLibrary] = [:]
    private var _time: Time = Time();
    private var _settings: EngineSettings? = nil
    private var _device: MTLDevice
    private var _sceneManager: SceneManager!
    private var _physicsManager: PhysicsManager!
    private var _inputManager: InputManager!
    private var _postprocessManager: PostprocessManager!
#if os(iOS)
    private var _arManager: ARManager?
#else
    private var _guiManager: GUIManager!
#endif

    private var _textureLoader: TextureLoader!

    private var _isPaused: Bool = true;

    /// Settings of Engine.
    public var settings: EngineSettings? {
        get {
            _settings
        }
    }

    /// Get the Metal device.
    public var device: MTLDevice {
        get {
            _device
        }
    }
    
    public var commandQueue: MTLCommandQueue {
        get {
            _commandQueue
        }
    }

    /// Get the texture loader.
    public var textureLoader: TextureLoader {
        get {
            _textureLoader
        }
    }
    
    /// Get the post-process manager.
    public var postprocessManager: PostprocessManager {
        get {
            _postprocessManager
        }
    }

    /// Get the scene manager.
    public var sceneManager: SceneManager {
        get {
            _sceneManager
        }
    }

    /// Get the physics manager.
    public var physicsManager: PhysicsManager {
        get {
            _physicsManager
        }
    }

    /// Get the input manager.
    public var inputManager: InputManager {
        get {
            _inputManager
        }
    }

#if os(iOS)
    /// Get the ar manager.
    public var arManager: ARManager? {
        get {
            _arManager
        }
    }
#endif

    /// Get the timer.
    public var time: Time {
        get {
            _time
        }
    }

    /// Whether the engine is paused.
    public var isPaused: Bool {
        get {
            _isPaused
        }
        set {
            _isPaused = newValue
            if !newValue {
                _time.reset()
            }
        }
    }

    public init(canvas: Canvas) {
        self.canvas = canvas
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        _device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to create default Metal Device")
        }
        self._commandQueue = commandQueue

        super.init()
        _ = createShaderLibrary("vox.shader")
        _physicsManager = PhysicsManager(engine: self)
        _inputManager = InputManager(engine: self)
        _sceneManager = SceneManager(engine: self)
        _sceneManager.activeScene = Scene(self, "DefaultScene")
        _postprocessManager = PostprocessManager(self)
        canvas.delegate = self
        canvas.device = device
        canvas.inputManager = _inputManager
        _textureLoader = TextureLoader(self)

#if os(macOS)
        _guiManager = GUIManager(self)
#endif
    }

#if os(iOS)
    public func initArSession() {
        _arManager = ARManager(device)
        let scene = _sceneManager.activeScene!
        scene.background.mode = .AR
        scene.background.ar = ARSubpass(self)
    }
#endif
    
    public func createShaderLibrary(_ name: String) -> MTLLibrary {
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
    
    public func library(_ name: String = "vox.shader") -> MTLLibrary {
        if let library = _library[name] {
            return library
        } else {
            return createShaderLibrary(name)
        }
    }

    /// Execution engine loop.
    public func run() {
        isPaused = false
    }

    /// Update the engine loop manually. If you call engine.run(), you generally don't need to call this function.
    func update() {
        let deltaTime = time.deltaTime;
        time.tick();

        if !_isPaused {
            let scene = _sceneManager._activeScene
            let componentsManager = _componentsManager
            if (scene != nil) {
                scene!._activeCameras.sort { camera1, camera2 in
                    camera1.priority > camera2.priority
                }

                componentsManager.callScriptOnStart()
                _physicsManager._update(deltaTime)
                _inputManager._update()
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
        arManager?.update(_time.deltaTime)
#endif
        _componentsManager.callRendererOnUpdate(_time.deltaTime)

        scene._updateShaderData()

        let cameras = scene._activeCameras
        if (cameras.count > 0) {
            if let commandBuffer = commandQueue.makeCommandBuffer(),
               let currentDrawable = canvas.currentDrawable {
                for camera in cameras {
                    _componentsManager.callCameraOnBeginRender(camera, commandBuffer)
                    camera.render(commandBuffer)
                    _componentsManager.callCameraOnEndRender(camera, commandBuffer)
                }
                _postprocessManager.render(commandBuffer)
#if os(macOS)
                _guiManager.draw(commandBuffer)
#endif
                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
            }
        } else {
            logger.debug("NO active camera.")
        }
    }
}

extension Engine: MTKViewDelegate {
    /// Called whenever the drawableSize of the view will change
    /// - Remark: Delegate can recompute view and projection matrices or regenerate any buffers
    /// to be compatible with the new view size or resolution
    /// - Parameters:
    ///   - view: MTKView which called this method
    ///   - size: New drawable size in pixels
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        canvas.dispatchResize()
    }

    /// Called on the delegate when it is asked to render into the view
    /// - Remark: Called on the delegate when it is asked to render into the view
    /// - Parameter view:  MTKView which called this method
    public func draw(in view: MTKView) {
        update()
    }
}
