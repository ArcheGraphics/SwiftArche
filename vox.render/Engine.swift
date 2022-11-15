//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Logging

let logger = Logger(label: "com.arche.main")

public class Engine {
    let _componentsManager: ComponentsManager = ComponentsManager()
    let _lightManager = LightManager()
    var sceneManager: SceneManager!
    var canvas: Canvas
    var device: MTLDevice
    var commandQueue: MTLCommandQueue;
    var _macroCollection: ShaderMacroCollection = ShaderMacroCollection()
        
    init(canvas: Canvas) {
        self.canvas = canvas
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        self.device = device
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to create default Metal Device")
        }
        self.commandQueue = commandQueue
        sceneManager = SceneManager(engine: self)
    }
    
    /// Update the engine loop manually. If you call engine.run(), you generally don't need to call this function.
    func update(_ deltaTime: Float) {
        let scene = sceneManager._activeScene
        let componentsManager = _componentsManager
        if (scene != nil) {
            scene!._activeCameras.sort { camera1, camera2 in
                camera1.priority > camera2.priority
            }
            
            componentsManager.callScriptOnStart()
            // physicsManager._initialized && physicsManager._update(deltaTime / 1000.0)
            // inputManager._update()
            componentsManager.callScriptOnUpdate(deltaTime)
            // componentsManager.callAnimationUpdate(deltaTime)
            componentsManager.callScriptOnLateUpdate(deltaTime)
            _render(scene!, deltaTime)
        }
        componentsManager.handlingInvalidScripts()
    }
    
    func _render(_ scene: Scene, _ deltaTime: Float) {
        let cameras = scene._activeCameras
        _componentsManager.callRendererOnUpdate(deltaTime)
        
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
