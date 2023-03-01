//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

class MyCharacterController: Script {
    public var Motor: KinematicCharacterMotor?

    override func onStart() {
        Motor!.CharacterController = self
    }
}

extension MyCharacterController: ICharacterController {
    func UpdateRotation(currentRotation: inout Quaternion, deltaTime: Float) {
    }
    
    func UpdateVelocity(currentVelocity: inout Vector3, deltaTime: Float) {
    }
    
    func BeforeCharacterUpdate(deltaTime: Float) {
    }
    
    func PostGroundingUpdate(deltaTime: Float) {
    }
    
    func AfterCharacterUpdate(deltaTime: Float) {
    }
    
    func IsColliderValidForCollisions(_ coll: Collider) -> Bool {
        true
    }
    
    func OnGroundHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                     hitStabilityReport: inout HitStabilityReport) {
    }
    
    func OnMovementHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                       hitStabilityReport: inout HitStabilityReport) {
    }
    
    func ProcessHitStabilityReport(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3, atCharacterPosition: Vector3,
                                   atCharacterRotation: Quaternion, hitStabilityReport: inout HitStabilityReport) {
    }
    
    func OnDiscreteCollisionDetected(hitCollider: Collider) {
    }
}
