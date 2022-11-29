//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class GeometryGenerator: Script {
    var quat: Quaternion = Quaternion(0, 0, 0.3, 0.7)

    override func onAwake() {
        _ = quat.normalize()
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        if (inputManager.isPointerTrigger(.leftMouseDown)) {
            if (Float.random(in: 0...1) > 0.5) {
                _ = addSphere(entity, 0.5, Vector3(floor(Float.random(in: 0...6)) - 2.5, 5, floor(Float.random(in: 0...6)) - 2.5), quat)
            } else {
                _ = addCapsule(entity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...6)) - 2.5, 5, floor(Float.random(in: 0...6)) - 2.5), quat)
            }
        }
    }
}

class PhysXRaycastApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 1, y: 1, z: 1)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 0, y: 3, z: 0)
        let pointLight: PointLight = light.addComponent()
        pointLight.intensity = 0.3

        let cubeEntity = rootEntity.createChild()
        let renderer: MeshRenderer = cubeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, 0.1, 0.1, 0.1)
        let material = PBRMaterial(engine)
        material.baseColor = Color(0.4, 0.0, 0.0)
        renderer.setMaterial(material)

        engine.run()
    }
}

