//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class MoveScript: Script {
    private var _rTri: Float = 0

    override func onUpdate(_ deltaTime: Float) {
        _rTri += 90 * deltaTime
        entity.transform.rotation = Vector3(0, _rTri, 0)
    }
}

class PrimitiveApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(5, 5, 5)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        let cubeEntity = rootEntity.createChild()
        cubeEntity.addComponent(MoveScript.self)
        let renderer = cubeEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createCuboid(engine)
        let material = PBRMaterial(engine)
        material.baseColor = Color(0.7, 0.0, 0.0)
        renderer.setMaterial(material)

        engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        engine.destroy()
    }
}

