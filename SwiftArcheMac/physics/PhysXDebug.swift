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
        sphereRenderer = entity.getComponent()
    }

    override func onTriggerEnter(_ other: ColliderShape) {
        _ = (sphereRenderer.getMaterial() as! PBRMaterial).baseColor.set(r: Float.random(in: 0..<1),
                g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
    }

    override func onTriggerExit(_ other: ColliderShape) {
        _ = (sphereRenderer.getMaterial() as! PBRMaterial).baseColor.set(r: Float.random(in: 0..<1),
                g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
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

class PhysXDebugApp: NSViewController {
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
        cameraEntity.transform.setPosition(x: 10, y: 10, z: 10)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 1, y: 3, z: 0)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        // create box test entity
        let cubeSize: Float = 2.0
        let boxEntity = rootEntity.createChild("BoxEntity")

        let boxMtl = PBRMaterial(engine)
        let boxRenderer: MeshRenderer = boxEntity.addComponent()
        _ = boxMtl.baseColor.set(r: 0.6, g: 0.3, b: 0.3, a: 1.0)
        boxMtl.metallic = 0.0
        boxMtl.roughness = 0.5
        boxRenderer.mesh = PrimitiveMesh.createCuboid(engine, cubeSize, cubeSize, cubeSize)
        boxRenderer.setMaterial(boxMtl)

        let physicsBox = BoxColliderShape()
        physicsBox.size = Vector3(cubeSize, cubeSize, cubeSize)
        physicsBox.material.staticFriction = 0.1
        physicsBox.material.dynamicFriction = 0.2
        physicsBox.material.bounciness = 1
        physicsBox.isTrigger = true

        let boxCollider: StaticCollider = boxEntity.addComponent()
        boxCollider.addShape(physicsBox)

        // create sphere test entity
        let radius: Float = 1.25
        let sphereEntity = rootEntity.createChild("SphereEntity")
        sphereEntity.transform.setPosition(x: -2, y: 0, z: 0)

        let sphereMtl = PBRMaterial(engine)
        let sphereRenderer: MeshRenderer = sphereEntity.addComponent()
        _ = sphereMtl.baseColor.set(r: Float.random(in: 0..<1), g: Float.random(in: 0..<1), b: Float.random(in: 0..<1), a: 1.0)
        sphereMtl.metallic = 0.0
        sphereMtl.roughness = 0.5
        sphereRenderer.mesh = PrimitiveMesh.createSphere(engine, radius)
        sphereRenderer.setMaterial(sphereMtl)

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        physicsSphere.material.staticFriction = 0.1
        physicsSphere.material.dynamicFriction = 0.2
        physicsSphere.material.bounciness = 1
        // sphereEntity.transform.setScale(3,3,3)

        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        sphereCollider.isKinematic = true
        sphereCollider.addShape(physicsSphere)

        let _: CollisionScript = sphereEntity.addComponent()
        let _: MoveScript = sphereEntity.addComponent()

        //MARK: - debug draw
        let wireframe: WireframeManager = rootEntity.addComponent()
        wireframe.addEntityWireframe(with: sphereEntity)
        wireframe.addEntityWireframe(with: boxEntity)

        engine.run()
    }
}

