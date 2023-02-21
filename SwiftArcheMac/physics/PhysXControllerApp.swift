//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import vox_render
import vox_math
import vox_toolkit

class ControllerScript: Script {
    var camera: Entity!
    var character: CharacterController?
    var displacement = Vector3()
    var _fallAccumulateTime: Float = 0
    
    required init(_ entity: Entity) {
        character = entity.getComponent()
        super.init(entity)
    }
    
    override func onUpdate(_ deltaTime: Float) {
        let inputManager = engine.inputManager
        if inputManager.isKeyHeldDown() {
            var forward = camera.transform.worldForward
            forward.y = 0
            _ = forward.normalize()
            var cross = Vector3(forward.z, 0, -forward.x)
            
            let animationSpeed: Float = 0.1
            if inputManager.isKeyHeldDown(.VKEY_W) {
                displacement = forward.scale(s: animationSpeed)
            }
            if inputManager.isKeyHeldDown(.VKEY_S) {
                displacement = forward.scale(s: -animationSpeed)
            }
            if inputManager.isKeyHeldDown(.VKEY_A) {
                displacement = cross.scale(s: animationSpeed)
            }
            if inputManager.isKeyHeldDown(.VKEY_D) {
                displacement = cross.scale(s: -animationSpeed)
            }
            if inputManager.isKeyHeldDown(.VKEY_SPACE) {
                displacement = Vector3(0, 0.05, 0)
            }
        } else {
            displacement = Vector3()
        }
    }
    
    override func onPhysicsUpdate() {
        if let character = character {
            let physicsManager = engine.physicsManager
            let gravity = physicsManager.gravity
            let fixedTimeStep = physicsManager.fixedTimeStep
            _fallAccumulateTime += fixedTimeStep
            
            _ = character.move(disp: displacement, minDist: 0.001, elapsedTime: fixedTimeStep)
            let flags = character.move(disp: Vector3(0, gravity.y * fixedTimeStep * _fallAccumulateTime, 0),
                                       minDist: 0.001, elapsedTime: fixedTimeStep)
            if flags & ControllerCollisionFlag.Down.rawValue != 0 {
                _fallAccumulateTime = 0
            }
        }
        
    }
}

class PhysXControllerApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    var rootEntity: Entity!

    func addPlane(_ size: Vector3, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(0.2179807202597362,
                              0.2939682161541871,
                              0.31177952549087604,
                              1.0)
        mtl.roughness = 0.0
        mtl.metallic = 0.0
        mtl.shader[0].setRenderFace(RenderFace.Double)
        let planeEntity = rootEntity.createChild()
        planeEntity.layer = Layer.Layer1

        let renderer: MeshRenderer = planeEntity.addComponent()
        renderer.mesh = PrimitiveMesh.createCuboid(engine, size.x, size.y, size.z)
        renderer.setMaterial(mtl)
        planeEntity.transform.position = position
        planeEntity.transform.rotationQuaternion = rotation

        let physicsPlane = PlaneColliderShape()
        let planeCollider: StaticCollider = planeEntity.addComponent()
        planeCollider.addShape(physicsPlane)

        return planeEntity
    }
    
    func addBox(_ size: Vector3, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        let boxEntity = rootEntity.createChild()
        let renderer: MeshRenderer = boxEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCuboid(engine, size.x, size.y, size.z)
        renderer.setMaterial(mtl)
        boxEntity.transform.position = position
        boxEntity.transform.rotationQuaternion = rotation

        let physicsBox = BoxColliderShape()
        physicsBox.size = size
        physicsBox.material.staticFriction = 1
        physicsBox.material.dynamicFriction = 2
        physicsBox.material.bounciness = 0.1
        physicsBox.isTrigger = false

        let boxCollider: DynamicCollider = boxEntity.addComponent()
        boxCollider.addShape(physicsBox)

        return boxEntity
    }

    func addSphere(_ radius: Float, _ position: Vector3, _ rotation: Quaternion, _ velocity: Vector3) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        let sphereEntity = rootEntity.createChild()
        let renderer: MeshRenderer = sphereEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createSphere(engine, radius)
        renderer.setMaterial(mtl)
        sphereEntity.transform.position = position
        sphereEntity.transform.rotationQuaternion = rotation

        let physicsSphere = SphereColliderShape()
        physicsSphere.radius = radius
        physicsSphere.material.staticFriction = 0.1
        physicsSphere.material.dynamicFriction = 0.2
        physicsSphere.material.bounciness = 1
        physicsSphere.material.bounceCombine = PhysicsMaterialCombineMode.Minimum

        let sphereCollider: DynamicCollider = sphereEntity.addComponent()
        sphereCollider.addShape(physicsSphere)
        sphereCollider.linearVelocity = velocity
        sphereCollider.angularDamping = 0.5

        return sphereEntity
    }

    func addCapsule(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        let capsuleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = capsuleEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCapsule(engine, radius, height)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let capsuleCollider: DynamicCollider = capsuleEntity.addComponent()
        capsuleCollider.addShape(physicsCapsule)

        return capsuleEntity
    }
    
    func addPlayer(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        mtl.roughness = 0.0
        mtl.metallic = 0.0
        let capsuleEntity = rootEntity.createChild()
        let renderer: MeshRenderer = capsuleEntity.addComponent()

        renderer.mesh = PrimitiveMesh.createCapsule(engine, radius, height, 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let characterController: CharacterController = capsuleEntity.addComponent()
        characterController.addShape(physicsCapsule)

        return capsuleEntity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvas = Canvas(with: view)
        engine = Engine(canvas: canvas)
        iblBaker = IBLBaker(engine)
        
        let scene = engine.sceneManager.activeScene!
        let hdr = engine.textureLoader.loadHDR(with: "assets/kloppenheim_06_4k.hdr")!
        iblBaker.bake(scene, with: hdr, size: 256, level: 3)
        
        rootEntity = scene.createRootEntity()
        let cameraEntity = rootEntity.createChild()
        cameraEntity.transform.position = Vector3(20, 20, 20)
        cameraEntity.transform.lookAt(targetPosition: Vector3())
        let _: Camera = cameraEntity.addComponent()
        let _: OrbitControl = cameraEntity.addComponent()
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight: DirectLight = light.addComponent()
        directLight.shadowType = ShadowType.SoftLow

        let player = addPlayer(1, 3, Vector3(0, 6.5, 0), Quaternion())
        let controller: ControllerScript = player.addComponent()
        controller.camera = cameraEntity

        _ = addPlane(Vector3(30, 0.1, 30), Vector3(), Quaternion())
        for i in 0..<5 {
            let i = Float(i)
            for j in 0..<5 {
                let j = Float(j)
                _ = addBox(Vector3(1, 1, 1),
                        Vector3(-2.5 + i + 0.1 * i, floor(Float.random(in: 0..<1) * 6) + 1, -2.5 + j + 0.1 * j),
                        Quaternion(0, 0, 0.3, 0.7))
            }
        }
        
        engine.run()
    }
}