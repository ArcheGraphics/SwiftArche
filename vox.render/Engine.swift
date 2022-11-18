//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ARKit
import MetalKit
import Metal
import Logging

let logger = Logger(label: "com.arche.main")

public class Engine: NSObject {
    let canvas: Canvas
    let session: ARSession?
    let library: MTLLibrary!
    let commandQueue: MTLCommandQueue
    let _macroCollection: ShaderMacroCollection = ShaderMacroCollection()
    let _componentsManager: ComponentsManager = ComponentsManager()
    let _lightManager = LightManager()

    private var _time: Time = Time();
    private var _settings: EngineSettings? = nil
    private var _device: MTLDevice
    private var _sceneManager: SceneManager!
    private var _physicsManager: PhysicsManager!
    private var _inputManager: InputManager!

    private var _isPaused: Bool = true;

    /// Settings of Engine.
    var settings: EngineSettings? {
        get {
            _settings
        }
    }

    /// Get the Metal device.
    var device: MTLDevice {
        get {
            _device
        }
    }

    /// Get the scene manager.
    var sceneManager: SceneManager {
        get {
            _sceneManager
        }
    }

    /// Get the input manager.
    var physicsManager: PhysicsManager {
        get {
            _physicsManager
        }
    }

    /// Get the input manager.
    var inputManager: InputManager {
        get {
            _inputManager
        }
    }

    /// Get the timer.
    var time: Time {
        get {
            _time
        }
    }

    /**
   * Whether the engine is paused.
   */
    var isPaused: Bool {
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

    public init(canvas: Canvas, session: ARSession? = nil) {
        self.session = session
        self.canvas = canvas
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        _device = device

        // Load all the shader files with a metal file extension in the project
        let libraryURL = Bundle.main.url(forResource: "vox.shader", withExtension: "metallib")!
        do {
            library = try device.makeLibrary(URL: libraryURL)
        } catch let error {
            fatalError("Error creating MetalKit mesh, error \(error)")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to create default Metal Device")
        }
        self.commandQueue = commandQueue

        super.init()
        _sceneManager = SceneManager(engine: self)
        _sceneManager.activeScene = Scene(self, "DefaultScene");
        _physicsManager = PhysicsManager(engine: self)
        _inputManager = InputManager(engine: self)
        canvas.delegate = self
        session?.delegate = self
    }

    /// Execution engine loop.
    func run() {
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
                // componentsManager.callAnimationUpdate(deltaTime)
                componentsManager.callScriptOnLateUpdate(deltaTime)
                _render(scene!)
            }
            componentsManager.handlingInvalidScripts()
        }
    }

    func _render(_ scene: Scene) {
        let cameras = scene._activeCameras
        _componentsManager.callRendererOnUpdate(_time.deltaTime)

        scene._updateShaderData()

        if (cameras.count > 0) {
            for camera in cameras {
                _componentsManager.callCameraOnBeginRender(camera)
                camera.render()
                _componentsManager.callCameraOnEndRender(camera)
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
    }

    /// Called on the delegate when it is asked to render into the view
    /// - Remark: Called on the delegate when it is asked to render into the view
    /// - Parameter view:  MTKView which called this method
    public func draw(in view: MTKView) {
        update()
    }
}

extension Engine: ARSessionDelegate {
    ///
    /// This is called when a new frame has been updated.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - frame: The frame that has been updated.
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

    /// This is called when new anchors are added to the session.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of added anchors.
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }

    /// This is called when anchors are updated.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of updated anchors.
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    }

    /// This is called when anchors are removed from the session.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - anchors: An array of removed anchors.
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    }

    ///  This is called when a session fails.
    /// - Parameters:
    ///   - session: The session that failed.
    ///   - error: The error being reported (see ARError.h).
    /// - Remark: On failure the session will be paused.
    public func session(_ session: ARSession, didFailWithError error: Error) {
    }

    /// This is called when the camera’s tracking state has changed.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - camera: The camera that changed tracking states.
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }

    /// This is called when a session is interrupted.
    /// - Remark: A session will be interrupted and no longer able to track when
    /// it fails to receive required sensor data. This happens when video capture is interrupted,
    /// for example when the application is sent to the background or when there are
    /// multiple foreground applications (see AVCaptureSessionInterruptionReason).
    /// No additional frame updates will be delivered until the interruption has ended.
    /// - Parameter session: The session that was interrupted.
    public func sessionWasInterrupted(_ session: ARSession) {
    }

    /// This is called when a session interruption has ended.
    /// - Remark: A session will continue running from the last known state once
    /// the interruption has ended. If the device has moved, anchors will be misaligned.
    /// To avoid this, some applications may want to reset tracking (see ARSessionRunOptions)
    /// or attempt to relocalize (see `-[ARSessionObserver sessionShouldAttemptRelocalization:]`).
    /// - Parameter session: The session that was interrupted.
    public func sessionInterruptionEnded(_ session: ARSession) {
    }

    /// This is called after a session resumes from a pause or interruption to determine
    /// whether or not the session should attempt to relocalize.
    /// - Remark:  To avoid misaligned anchors, apps may wish to attempt a relocalization after
    /// a session pause or interruption. If YES is returned: the session will begin relocalizing
    /// and tracking state will switch to limited with reason relocalizing. If successful, the
    /// session's tracking state will return to normal. Because relocalization depends on
    /// the user's location, it can run indefinitely. Apps that wish to give up on relocalization
    /// may call run with `ARSessionRunOptionResetTracking` at any time.
    /// - Parameter session: The session to relocalize.
    /// - Returns: Return YES to begin relocalizing.
    @available(iOS 11.3, macCatalyst 13.1, *)
    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        true
    }

    /// This is called when the session outputs a new audio sample buffer.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - audioSampleBuffer: The captured audio sample buffer.
    public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
    }

    /// This is called when the session generated new collaboration data.
    /// - Remark: This data should be sent to all participants.
    /// - Parameters:
    ///   - session: The session that produced world tracking collaboration data.
    ///   - data: Collaboration data to be sent to participants.
    @available(iOS 13.0, macCatalyst 13.1, *)
    public func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    }

    ///
    /// This is called when geo tracking status changes.
    /// - Parameters:
    ///   - session: The session being run.
    ///   - geoTrackingStatus: Latest geo tracking status.
    @available(iOS 14.0, *)
    public func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
    }
}