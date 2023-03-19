//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

public class ControlledPlayer: Script {
    public var camera: Entity!
    var character: CharacterController?
    var displacement = Vector3()
    
    public var jump = Jump()
    
    public override func onStart() {
        character = entity.getComponent(CharacterController.self)
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
                startJump()
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
            
            let heightDelta = jump.getHeight(elapsedTime: fixedTimeStep)
            var dy: Float = 0
            if(heightDelta != 0.0) {
                dy = heightDelta;
            } else {
                dy = gravity.y * fixedTimeStep;
            }
            displacement.y = dy

            let flags = character.move(disp: displacement, minDist: 0.01, elapsedTime: fixedTimeStep)
            if flags.contains(ControllerCollisionFlag.Down) {
                jump.stopJump()
            }
        }
    }
    
    func startJump() {
        if let character = character,
           character.isGrounded {
            jump.startJump()
        }
    }
}

public struct Jump {
    public var jumpGravity: Float = -50.0
    public var jumpForce: Float = 30

    private var jump: Bool = false
    private var jumpTime: Float = 0

    mutating func startJump() {
        if (jump) {
            return
        }
        jumpTime = 0.0
        jump = true
    }

    mutating func stopJump() {
        if (!jump) {
            return
        }
        jump = false
    }

    mutating func getHeight(elapsedTime: Float) -> Float {
        if (!jump) {
            return 0.0
        }
        jumpTime += elapsedTime
        let h = jumpGravity * jumpTime * jumpTime + jumpForce * jumpTime
        return h * elapsedTime
    }
}
