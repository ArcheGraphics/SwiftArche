//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import UIKit
import ARKit
import vox_render
import vox_math

class MoveScript: Script {
    private var _rTri: Float = 0
    private var _cubeEntity:Entity?

    override func onUpdate(_ deltaTime: Float) {
        _rTri += 90 * deltaTime
        if _cubeEntity != nil {
            _cubeEntity!.transform.setRotation(x: 0, y: _rTri, z: 0)
        }
    }
    
    override func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
        if _cubeEntity == nil {
            _cubeEntity = entity.createChild()
            let renderer: MeshRenderer = _cubeEntity!.addComponent()
            renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
            let material = UnlitMaterial(engine)
            material.baseColor = Color(0.4, 0.6, 0.6)
            renderer.setMaterial(material)
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            _cubeEntity!.transform.localMatrix = Matrix(simd_mul(frame.camera.transform, translation))
        }
    }
}

class PrimitiveApp: UIViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)

        engine = Engine(canvas: canvas)
        engine.initArSession()

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()
        let _:MoveScript = rootEntity.addComponent()
        
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 10, y: 10, z: 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3(0, 0, 0))
        let camera: Camera = cameraEntity.addComponent()
        engine.arManager!.camera = camera
        
        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        engine.run()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        engine.arManager?.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        engine.arManager?.pause()
    }
}

