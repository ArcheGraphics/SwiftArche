//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

fileprivate class ShootScript: Script {
    var ray = Ray()
    var position = Vector3()
    var rotation = Quaternion()
    var camera: Camera!

    override func onAwake() {
        camera = entity.getComponent()
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        if (!inputManager.pointers.isEmpty && inputManager.isPointerTrigger(.leftMouseDown)) {
            _ = camera.screenPointToRay(inputManager.pointers[0].screenPoint(engine.canvas), ray)
            ray.direction *= 50
            _ = addSphere(entity, 0.5, position, rotation, ray.direction)
        }
    }

    private func addSphere(_ rootEntity: Entity, _ radius: Float, _ position: Vector3,
                           _ rotation: Quaternion, _ velocity: Vector3) -> Entity {
        let mtl = PBRMaterial(rootEntity.engine)
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
        mtl.roughness = 0.5
        mtl.metallic = 0.0
        let sphereEntity = rootEntity.createChild()
        let renderer: MeshRenderer = sphereEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createSphere(rootEntity.engine, radius)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearVelocity = velocity
        sphereCollider.angularDamping = 0.5

        return sphereEntity
    }
}

class PhysXJointBasicApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!

    func transform(_ position: Vector3, _ rotation: Quaternion, _ outPosition: inout Vector3, _ outRotation: inout Quaternion) {
        outRotation *= rotation
        outPosition = Vector3.transformByQuat(v: outPosition, quaternion: rotation) + position
    }

    func createChain(_ rootEntity: Entity, _ position: Vector3, _ rotation: Quaternion, _ length: Int, _ separation: Float) {
        var prevCollider: Collider? = nil
        for i in 0..<length {
            var localPosition = Vector3(0, -separation / 2 * Float(2 * i + 1), 0)
            var localQuaternion = Quaternion()
            transform(position, rotation, &localPosition, &localQuaternion)
            let currentEntity = addBox(rootEntity, Vector3(2.0, 2.0, 0.5), localPosition, localQuaternion)

            let currentCollider: DynamicCollider? = currentEntity.getComponent()
            let fixedJoint: FixedJoint = currentEntity.addComponent()
            if (prevCollider != nil) {
                fixedJoint.connectedAnchor = currentEntity.transform.worldPosition - prevCollider!.entity.transform.worldPosition
                fixedJoint.connectedCollider = prevCollider
            } else {
                fixedJoint.connectedAnchor = position
            }
            prevCollider = currentCollider
        }
    }

    func createSpring(_ rootEntity: Entity, _ position: Vector3, _ rotation: Quaternion) {
        let currentEntity = addBox(rootEntity, Vector3(2, 2, 1), position, rotation)
        let springJoint: SpringJoint = currentEntity.addComponent()
        springJoint.connectedAnchor = position
        springJoint.swingOffset = Vector3(0, 1, 0)
        springJoint.maxDistance = 2
        springJoint.stiffness = 0.2
        springJoint.damping = 1
    }

    func createHinge(_ rootEntity: Entity, _ position: Vector3, _ rotation: Quaternion) {
        let currentEntity = addBox(rootEntity, Vector3(4.0, 4.0, 0.5), position, rotation)
        let hingeJoint: HingeJoint = currentEntity.addComponent()
        hingeJoint.connectedAnchor = position
        hingeJoint.swingOffset = Vector3(0, 1, 0)
        hingeJoint.axis = Vector3(0, 1, 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)

        let scene = engine.sceneManager.activeScene!
        let cubeMap = try! engine.textureLoader.loadTexture(with: "country")!
        scene.ambientLight = loadAmbientLight(engine, withLDR: cubeMap, format: .rgba8Unorm, lodStart: 3, lodEnd: 4)
        let rootEntity = scene.createRootEntity()

        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.setPosition(x: 3, y: 1, z: 22)
        cameraEntity.transform.lookAt(targetPosition: Vector3(3, 1, 0))
        let _: Camera = cameraEntity.addComponent()
        let _: ShootScript = cameraEntity.addComponent();

        let light = rootEntity.createChild("light")
        light.transform.setPosition(x: 1, y: 3, z: 0)
        light.transform.lookAt(targetPosition: Vector3())
        let _: DirectLight = light.addComponent()

        createChain(rootEntity, Vector3(8.0, 10.0, 0.0), Quaternion(), 10, 2.0)
        createSpring(rootEntity, Vector3(-4.0, 4.0, 1.0), Quaternion())
        createHinge(rootEntity, Vector3(0, 0, 0), Quaternion())

        engine.run()
    }
}

