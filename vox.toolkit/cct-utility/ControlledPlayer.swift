//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class ControlledPlayer: Script {
    public var camera: Entity!
    var character: CharacterController?
    var displacement = Vector3()
    
    required init(_ entity: Entity) {
        character = entity.getComponent(CharacterController.self)
        character!.behavior = PlayerBehavior()
        super.init(entity)
    }
    
    public override func onUpdate(_ deltaTime: Float) {
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
    
    public override func onPhysicsUpdate() {
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
