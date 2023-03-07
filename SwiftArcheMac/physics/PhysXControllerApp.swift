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
    
    required init(_ entity: Entity) {
        character = entity.getComponent(CharacterController.self)
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
                displacement = Vector3(0, 0.5, 0)
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
            displacement.y += gravity.y * fixedTimeStep
            
            _ = character.move(disp: displacement, minDist: 0.01, elapsedTime: fixedTimeStep)
        }
        
    }
}

class PlayerBehavior: ControllerBehavior {
    override init() {
        super.init()
    }
    
    override func onShapeHit(hit: ControllerColliderHit) {
        if let rigidBody = hit.collider as? DynamicCollider {
            if !rigidBody.isKinematic {
                var dir = hit.entity!.transform.worldPosition - hit.controller!.entity.transform.worldPosition
                dir.y = 0
                rigidBody.applyForceAtPosition(dir.normalized() * 10,
                                               hit.controller!.entity.transform.worldPosition,
                                               mode: eIMPULSE)
            }
        }
    }
    
    override func getShapeBehaviorFlags(shape: ColliderShape) -> ControllerBehaviorFlag {
        [ControllerBehaviorFlag.CanRideOnObject, ControllerBehaviorFlag.Slide]
    }
}

class MovablePlatform : Script {
    var boxEntity: Entity
    var time: Float = 0
    var platform: DynamicCollider?
    
    required init(_ entity: Entity) {
        boxEntity = addBox(entity, Vector3(5, 2, 5), Vector3(0, 2, 10), Quaternion(), isDynamic: true)
        platform = boxEntity.getComponent(DynamicCollider.self)
        if let platform {
            platform.isKinematic = true
            platform.setDensity(1)
        }
        super.init(entity)
    }

    override func onUpdate(_ deltaTime: Float) {
        time += deltaTime
        if let platform {
            platform.movePosition(Vector3(sin(time) * 15, sin(time) * 2 + 3, cos(time) * 15))
        }
    }
}

class PhysXControllerApp: NSViewController {
    var canvas: Canvas!
    var engine: Engine!
    var iblBaker: IBLBaker!
    var rootEntity: Entity!
    
    func addPlayer(_ radius: Float, _ height: Float, _ position: Vector3, _ rotation: Quaternion) -> Entity {
        let mtl = PBRMaterial(engine)
        mtl.baseColor = Color(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1), 1.0)
        mtl.roughness = 0.0
        mtl.metallic = 0.0
        let capsuleEntity = rootEntity.createChild()
        let renderer = capsuleEntity.addComponent(MeshRenderer.self)

        renderer.mesh = PrimitiveMesh.createCapsule(engine, radius: radius, height: height, radialSegments: 20)
        renderer.setMaterial(mtl)
        capsuleEntity.transform.position = position
        capsuleEntity.transform.rotationQuaternion = rotation

        let physicsCapsule = CapsuleColliderShape()
        physicsCapsule.radius = radius
        physicsCapsule.height = height

        let characterController = capsuleEntity.addComponent(CharacterController.self)
        characterController.addShape(physicsCapsule)
        characterController.behavior = PlayerBehavior()

        return capsuleEntity
    }
    
    func initialize(_ rootEntity: Entity) {
        var quat = Quaternion(0, 0, 0.3, 0.7)
        _ = quat.normalize()
        _ = addPlane(rootEntity, Vector3(30, 0.0, 30), Vector3(), Quaternion())
        for i in 0..<4 {
            for j in 0..<4 {
                let random = Int(floor(Float.random(in: 0...3))) % 3
                switch (random) {
                case 0:
                    _ = addBox(rootEntity, Vector3(3, 3, 3), Vector3(Float(-4 + i), floor(Float.random(in: 0...6)) + 5, Float(-4 + j)), quat)
                    break
                case 1:
                    _ = addSphere(rootEntity, 0.5, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4), quat)
                    break
                case 2:
                    _ = addCapsule(rootEntity, 0.5, 2.0, Vector3(floor(Float.random(in: 0...16)) - 4, 5, floor(Float.random(in: 0...16)) - 4), quat)
                    break
                default:
                    break
                }
            }
        }
        rootEntity.addComponent(MovablePlatform.self)
//        addDuckMesh(rootEntity)
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
        cameraEntity.addComponent(Camera.self)
        cameraEntity.addComponent(OrbitControl.self)
        
        let light = rootEntity.createChild("light")
        light.transform.position = Vector3(1, 3, 0)
        light.transform.lookAt(targetPosition: Vector3())
        let directLight = light.addComponent(DirectLight.self)
        directLight.shadowType = ShadowType.SoftLow

        let player = addPlayer(1, 3, Vector3(0, 6.5, 0), Quaternion())
        let controller = player.addComponent(ControllerScript.self)
        controller.camera = cameraEntity

        initialize(rootEntity)
        
        engine.run()
    }
}
