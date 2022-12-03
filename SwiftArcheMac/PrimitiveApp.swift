//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class MoveScript: Script {
    private var _rTri: Float = 0

    override func onUpdate(_ deltaTime: Float) {
        _rTri += 90 * deltaTime
        entity.transform.setRotation(x: 0, y: _rTri, z: 0)
    }
}

class PrimitiveApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let cubeMap = try! engine.textureLoader.loadTexture(with: "country")!
        scene.ambientLight = loadAmbientLight(engine, withLDR: cubeMap, format: .rgba8Unorm, lodStart: 3, lodEnd: 4)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 5, y: 5, z: 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 1, y: 3, z: 0)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        let cubeEntity = rootEntity.createChild()
        let _: MoveScript = cubeEntity.addComponent()
        let renderer: MeshRenderer = cubeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine)
        let material = PBRMaterial(engine)
        material.baseColor = Color(0.7, 0.0, 0.0)
        renderer.setMaterial(material)

        engine.run()
    }
}

