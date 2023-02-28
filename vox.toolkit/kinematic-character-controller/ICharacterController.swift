//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public protocol ICharacterController {
    /// This is called when the motor wants to know what its rotation should be right now
    func UpdateRotation(currentRotation: inout Quaternion, deltaTime: Float)
    /// This is called when the motor wants to know what its velocity should be right now
    func UpdateVelocity(currentVelocity: inout Vector3, deltaTime: Float)
    /// This is called before the motor does anything
    func BeforeCharacterUpdate(deltaTime: Float)
    /// This is called after the motor has finished its ground probing, but before PhysicsMover/Velocity/etc.... handling
    func PostGroundingUpdate(deltaTime: Float)
    /// This is called after the motor has finished everything in its update
    func AfterCharacterUpdate(deltaTime: Float)
    /// This is called after when the motor wants to know if the collider can be collided with (or if we just go through it)
    func IsColliderValidForCollisions(coll: Collider) -> Bool
    /// This is called when the motor's ground probing detects a ground hit
    func OnGroundHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                     hitStabilityReport: inout HitStabilityReport)
    /// This is called when the motor's movement logic detects a hit
    func OnMovementHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                       hitStabilityReport: inout HitStabilityReport)
    /// This is called after every move hit, to give you an opportunity to modify the HitStabilityReport to your liking
    func ProcessHitStabilityReport(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                                   atCharacterPosition: Vector3, atCharacterRotation: Quaternion,
                                   hitStabilityReport: inout HitStabilityReport)
    /// This is called when the character detects discrete collisions (collisions that don't result from the motor's capsuleCasts when moving)
    func OnDiscreteCollisionDetected(hitCollider: Collider)
}
