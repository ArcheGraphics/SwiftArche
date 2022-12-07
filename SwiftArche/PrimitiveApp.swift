//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import UIKit
import ARKit
import vox_render
import vox_math

class ARScript: Script {
    private var _rTri: Float = 0
    private var _cubeEntity: Entity?

    override func onARUpdate(_ deltaTime: Float, _ frame: ARFrame) {
        if _cubeEntity == nil {
            _cubeEntity = entity.createChild()
            let renderer: MeshRenderer = _cubeEntity!.addComponent()
            renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
            let material = PBRMaterial(engine)
            material.baseColor = Color(0.4, 0.6, 0.6)
            renderer.setMaterial(material)

            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            _cubeEntity!.transform.localMatrix = Matrix(simd_mul(frame.camera.transform, translation))
        }

        _rTri += 90 * deltaTime
        if _cubeEntity != nil {
            _cubeEntity!.transform.rotation = Vector3(0, _rTri, 0)
        }
    }
}

class PrimitiveApp: UIViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        engine.initArSession()
        iblBaker = IBLBaker(engine)

        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()
        let _: ARScript = rootEntity.addComponent()

        let cameraEntity = rootEntity.createChild()
        let camera: Camera = cameraEntity.addComponent()
        engine.arManager!.camera = camera

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        engine.run()
    }

    override func viewWillAppear(_ animated: Bool) {
        engine.arManager?.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        engine.arManager?.pause()
    }
}

