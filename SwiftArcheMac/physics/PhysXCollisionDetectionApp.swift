//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class CollisionScript: Script {
    private var sphereRenderer: MeshRenderer!

    override func onAwake() {
        sphereRenderer = entity.getComponent(MeshRenderer.self)
    }

    override func onTriggerEnter(_ other: ColliderShape) {
        (sphereRenderer.getMaterial() as! PBRMaterial).baseColor = Color(Float.random(in: 0..<1),
                Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
    }

    override func onTriggerExit(_ other: ColliderShape) {
        (sphereRenderer.getMaterial() as! PBRMaterial).baseColor = Color(Float.random(in: 0..<1),
                Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
    }
}

fileprivate class MoveScript: Script {
    var pos: Float = -5
    var vel: Float = 0.05
    var velSign: Float = -1

    override func onPhysicsUpdate() {
        if (pos >= 5) {
            velSign = -1
        }
        if (pos <= -5) {
            velSign = 1
        }
        pos += vel * velSign
        entity.transform.worldPosition = Vector3(pos, 0, 0)
    }
}

class PhysXCollisionDetectionApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
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
        cameraEntity.transform.position = Vector3(10, 10, 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        light.addComponent(DirectLight.self)

        // create box test entity
        let cubeSize: Float = 2.0
        let boxEntity = rootEntity.createChild("BoxEntity")

        let boxMtl = PBRMaterial(engine)
        let boxRenderer = boxEntity.addComponent(MeshRenderer.self)
        boxMtl.baseColor = Color(0.6, 0.3, 0.3, 1.0)
        boxMtl.metallic = 0.0
        boxMtl.roughness = 0.5
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, width: cubeSize, height: cubeSize, depth: cubeSize)
        boxRenderer.setMaterial(boxMtl)

        let physicsBox = BoxColliderShape()
        physicsBox.size = Vector3(cubeSize, cubeSize, cubeSize)
        physicsBox.material.staticFriction = 0.1
        physicsBox.material.dynamicFriction = 0.2
        physicsBox.material.bounciness = 1
        physicsBox.isTrigger = true

        let boxCollider = boxEntity.addComponent(StaticCollider.self)
        boxCollider.addShape(physicsBox)

        // create sphere test entity
        let radius: Float = 1.25
        let sphereEntity = rootEntity.createChild("SphereEntity")
        sphereEntity.transform.position = Vector3(-2, 0, 0)

        let sphereMtl = PBRMaterial(engine)
        let sphereRenderer = sphereEntity.addComponent(MeshRenderer.self)
        sphereMtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        sphereMtl.metallic = 0.0
        sphereMtl.roughness = 0.5
        sphereRenderer.mesh = PrimitiveMesh.createSphere(engine, radius: radius)
        sphereRenderer.setMaterial(sphereMtl)

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        physicsSphere.material.staticFriction = 0.1
        physicsSphere.material.dynamicFriction = 0.2
        physicsSphere.material.bounciness = 1
        // sphereEntity.transform.setScale(3,3,3)

        let sphereCollider = sphereEntity.addComponent(DynamicCollider.self)
        sphereCollider.isKinematic = true
        sphereCollider.addShape(physicsSphere)

        sphereEntity.addComponent(CollisionScript.self)
        sphereEntity.addComponent(MoveScript.self)

        engine.run()
    }
}

