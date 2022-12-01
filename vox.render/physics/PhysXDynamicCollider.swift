//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// The collision detection mode constants used for PhysXDynamicCollider.collisionDetectionMode.
public enum CollisionDetectionMode: Int {
    /// Continuous collision detection is off for this dynamic collider.
    case Discrete
    /// Continuous collision detection is on for colliding with static mesh geometry.
    case Continuous
    /// Continuous collision detection is on for colliding with static and dynamic geometry.
    case ContinuousDynamic
    /// Speculative continuous collision detection is on for static and dynamic geometries
    case ContinuousSpeculative
}

/// Use these flags to constrain motion of dynamic collider.
public enum DynamicColliderConstraints {
    /// Freeze motion along the X-axis.
    case FreezePositionX
    /// Freeze motion along the Y-axis.
    case FreezePositionY
    /// Freeze motion along the Z-axis.
    case FreezePositionZ
    /// Freeze rotation along the X-axis.
    case FreezeRotationX
    /// Freeze rotation along the Y-axis.
    case FreezeRotationY
    /// Freeze rotation along the Z-axis.
    case FreezeRotationZ
    /// Freeze motion along all axes.
    case FreezePosition
    /// Freeze rotation along all axes.
    case FreezeRotation
    /// Freeze rotation and motion along all axes.
    case FreezeAll
}

/// A dynamic collider can act with self-defined movement or physical force
class PhysXDynamicCollider: PhysXCollider {
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        var rotation = rotation
        _pxActor = PhysXPhysics._pxPhysics.createRigidDynamic(withPosition: position.internalValue,
                rotation: rotation.normalize().internalValue)
    }

    func setLinearDamping(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setLinearDamping(value)
    }

    func setAngularDamping(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setAngularDamping(value)
    }

    func setLinearVelocity(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setLinearVelocity(value.internalValue)
    }

    func setAngularVelocity(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setAngularVelocity(value.internalValue)
    }

    func setMass(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMass(value)
    }

    func setCenterOfMass(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setCMassLocalPose(value.internalValue,
                rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1))
    }

    func setInertiaTensor(_ value: Vector3) {
        (_pxActor as! CPxRigidDynamic).setMassSpaceInertiaTensor(value.internalValue)
    }

    func setMaxAngularVelocity(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMaxAngularVelocity(value)
    }

    func setMaxDepenetrationVelocity(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setMaxDepenetrationVelocity(value)
    }

    func setSleepThreshold(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setSleepThreshold(value)
    }

    func setSolverIterations(_ value: Int) {
        (_pxActor as! CPxRigidDynamic).setSolverIterationCounts(UInt32(value), minVelocityIters: 1)
    }

    func setCollisionDetectionMode(_ value: Int) {
        switch (value) {
        case CollisionDetectionMode.Continuous.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: true)
            break
        case CollisionDetectionMode.ContinuousDynamic.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: true)
            break
        case CollisionDetectionMode.ContinuousSpeculative.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: true)
            break
        case CollisionDetectionMode.Discrete.rawValue:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: false)
            break
        default:
            break
        }
    }

    func setIsKinematic(_ value: Bool) {
        if (value) {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: true)
        } else {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: false)
        }
    }

    func setConstraints(flags: Int32) {
        (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlags(flags)
    }

    func addForce(_ force: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForce(force.internalValue)
    }

    func addTorque(_ torque: Vector3) {
        (_pxActor as! CPxRigidDynamic).addTorque(torque.internalValue)
    }

    func addForceAtPosition(_ force: Vector3, _ pos: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForceAtPos(with: force.internalValue, pos: pos.internalValue, mode: eFORCE)
    }

    func movePosition(_ value: Vector3) {
        var position = SIMD3<Float>()
        var rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        _pxActor.getGlobalPose(&position, rotation: &rotation)

        (_pxActor as! CPxRigidDynamic).setKinematicTarget(value.internalValue, rotation: rotation)
    }

    func moveRotation(_ value: Quaternion) {
        var position = SIMD3<Float>()
        var rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        _pxActor.getGlobalPose(&position, rotation: &rotation)

        (_pxActor as! CPxRigidDynamic).setKinematicTarget(position, rotation: value.internalValue)
    }

    func sleep() {
        (_pxActor as! CPxRigidDynamic).putToSleep()
    }

    func wakeUp() {
        (_pxActor as! CPxRigidDynamic).wakeUp()
    }

    private func setConstraints(_ flag: DynamicColliderConstraints, _ value: Bool) {
        switch (flag) {
        case DynamicColliderConstraints.FreezePositionX:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            break
        case DynamicColliderConstraints.FreezePositionY:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezePositionZ:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationX:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationY:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotationZ:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        case DynamicColliderConstraints.FreezeAll:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        case DynamicColliderConstraints.FreezePosition:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_LINEAR_Y, value: value)
            break
        case DynamicColliderConstraints.FreezeRotation:
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_X, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Y, value: value)
            (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlag(eLOCK_ANGULAR_Z, value: value)
            break
        }
    }
}
