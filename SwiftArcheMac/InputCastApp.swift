//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class ClickScript: Script {
    private var material: PBRMaterial!

    override func onStart() {
        let renderer = entity.getComponent(MeshRenderer.self)!
        material = (renderer.getMaterial() as! PBRMaterial)
    }

    override func onPointerCast(_ hitResult: HitResult, _ type: UInt) {
        material.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
    }
}

class InputCastApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
    func createBox(_ rootEntity: Entity, _ x: Float, _ y: Float, _ z: Float) -> Entity {
        // create box test entity
        let cubeSize: Float = 2.0
        let boxEntity = rootEntity.createChild("BoxEntity")
        boxEntity.transform.position = Vector3(x, y, z)

        let boxMtl = PBRMaterial(engine)
        let boxRenderer = boxEntity.addComponent(MeshRenderer.self)
        boxMtl.baseColor = Color(0.6, 0.3, 0.3, 1.0)
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, width: cubeSize, height: cubeSize, depth: cubeSize)
        boxRenderer.setMaterial(boxMtl)

        let boxCollider = boxEntity.addComponent(StaticCollider.self)
        let boxColliderShape = BoxColliderShape()
        boxColliderShape.size = Vector3(cubeSize, cubeSize, cubeSize)
        boxCollider.addShape(boxColliderShape)
        return boxEntity
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
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

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        _ = createBox(rootEntity, 0, 0, 0).addComponent(ClickScript.self)

        engine.run()
    }
    
    override func viewDidDisappear() {
        engine.destroy()
    }
}

