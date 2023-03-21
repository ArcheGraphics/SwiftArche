//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import Math
import vox_toolkit

fileprivate class ShootScript: Script {
    var ray = Ray()
    var position = Vector3()
    var rotation = Quaternion()
    var camera: Camera!

    override func onAwake() {
        camera = entity.getComponent(Camera.self)
    }

    override func onUpdate(_ deltaTime: Float) {
        let inputManager = Engine.inputManager
        if (!inputManager.pointers.isEmpty && inputManager.isPointerTrigger(.leftMouseDown)) {
            _ = camera.screenPointToRay(inputManager.pointers[0].screenPoint(Engine.canvas), ray)
            ray.direction *= 50
            _ = addSphere(entity, 0.5, position, rotation, ray.direction)
        }
    }

    private func addSphere(_ rootEntity: Entity, _ radius: Float, _ position: Vector3,
                           _ rotation: Quaternion, _ velocity: Vector3) -> Entity {
        let mtl = PBRMaterial()
        mtl.baseColor = Color(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1.0)
        mtl.roughness = 0.5
        mtl.metallic = 0.0
        let sphereEntity = rootEntity.createChild()
        let renderer = sphereEntity.addComponent(MeshRenderer.self)
        renderer.mesh = PrimitiveMesh.createSphere(radius: radius)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        let sphereCollider = sphereEntity.addComponent(DynamicCollider.self)
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearVelocity = velocity
        sphereCollider.angularDamping = 0.5

        return sphereEntity
    }
}

class PhysXJointBasicApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    
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

            let currentCollider = currentEntity.getComponent(DynamicCollider.self)
            let fixedJoint = currentEntity.addComponent(FixedJoint.self)
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
        let springJoint = currentEntity.addComponent(SpringJoint.self)
        springJoint.connectedAnchor = position
        springJoint.swingOffset = Vector3(0, 1, 0)
        springJoint.maxDistance = 2
        springJoint.stiffness = 0.2
        springJoint.damping = 1
    }

    func createHinge(_ rootEntity: Entity, _ position: Vector3, _ rotation: Quaternion) {
        let currentEntity = addBox(rootEntity, Vector3(4.0, 4.0, 0.5), position, rotation)
        let hingeJoint = currentEntity.addComponent(HingeJoint.self)
        hingeJoint.connectedAnchor = position
        hingeJoint.swingOffset = Vector3(0, 1, 0)
        hingeJoint.axis = Vector3(0, 1, 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(frame: view.frame)
        canvas.setParentView(view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker()
        
        let scene = Engine.sceneManager.activeScene!
        let hdr = Engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)

        let rootEntity = scene.createRootEntity()
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(3, 1, 22)
        cameraEntity.transform.lookAt(targetPosition: Vector3(3, 1, 0))
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(ShootScript.self)

        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(-10, 10, 10)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = .SoftLow

        createChain(rootEntity, Vector3(8.0, 10.0, 0.0), Quaternion(), 10, 2.0)
        createSpring(rootEntity, Vector3(-4.0, 4.0, 1.0), Quaternion())
        createHinge(rootEntity, Vector3(0, 0, 0), Quaternion())

        Engine.run()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        Engine.destroy()
    }
}

