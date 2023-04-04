//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

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

public enum ForceMode: UInt8 {
    /// parameter has unit of mass * distance/ time^2, i.e. a force
    case Force = 0
    /// parameter has unit of mass * distance /time
    case Impulse = 1
    /// parameter has unit of distance / time, i.e. the effect is mass independent: a velocity change.
    case VelocityChange = 2
    /// parameter has unit of distance/ time^2, i.e. an acceleration.
    /// It gets treated just like a force except the mass is not divided out before integration.
    case Acceleration = 3
}

/// Use these flags to constrain motion of dynamic collider.
public struct DynamicColliderConstraints: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Freeze motion along the X-axis.
    public static let FreezePositionX = DynamicColliderConstraints(rawValue: 1 << 0)
    /// Freeze motion along the Y-axis.
    public static let FreezePositionY = DynamicColliderConstraints(rawValue: 1 << 1)
    /// Freeze motion along the Z-axis.
    public static let FreezePositionZ = DynamicColliderConstraints(rawValue: 1 << 2)
    /// Freeze rotation along the X-axis.
    public static let FreezeRotationX = DynamicColliderConstraints(rawValue: 1 << 3)
    /// Freeze rotation along the Y-axis.
    public static let FreezeRotationY = DynamicColliderConstraints(rawValue: 1 << 4)
    /// Freeze rotation along the Z-axis.
    public static let FreezeRotationZ = DynamicColliderConstraints(rawValue: 1 << 5)
}

/// A dynamic collider can act with self-defined movement or physical force
class PhysXDynamicCollider: PhysXCollider {
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _pxActor = PhysXPhysics._pxPhysics.createRigidDynamic(withPosition: position.internalValue,
                                                              rotation: rotation.normalized.internalValue)
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

    func getMass() -> Float {
        (_pxActor as! CPxRigidDynamic).getMass()
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

    func setCollisionDetectionMode(_ value: CollisionDetectionMode) {
        switch value {
        case CollisionDetectionMode.Continuous:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: true)
        case CollisionDetectionMode.ContinuousDynamic:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: true)
        case CollisionDetectionMode.ContinuousSpeculative:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: true)
        case CollisionDetectionMode.Discrete:
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_CCD_FRICTION, value: false)
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eENABLE_SPECULATIVE_CCD, value: false)
        }
    }

    func setIsKinematic(_ value: Bool) {
        if value {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: true)
        } else {
            (_pxActor as! CPxRigidDynamic).setRigidBodyFlag(eKINEMATIC, value: false)
        }
    }

    func setUseGravity(_ value: Bool) {
        (_pxActor as! CPxRigidDynamic).setUseGravity(value)
    }

    func setDensity(_ value: Float) {
        (_pxActor as! CPxRigidDynamic).setDensity(value)
    }

    func setConstraints(_ flags: DynamicColliderConstraints) {
        (_pxActor as! CPxRigidDynamic).setRigidDynamicLockFlags(flags.rawValue)
    }

    func addForce(_ force: Vector3) {
        (_pxActor as! CPxRigidDynamic).addForce(force.internalValue)
    }

    func addTorque(_ torque: Vector3) {
        (_pxActor as! CPxRigidDynamic).addTorque(torque.internalValue)
    }

    func addForceAtPosition(_ force: Vector3, _ pos: Vector3, _ mode: ForceMode) {
        (_pxActor as! CPxRigidDynamic).addForceAtPos(with: force.internalValue, pos: pos.internalValue, mode: mode.rawValue)
    }

    func movePosition(_ value: Vector3) {
        var position = SIMD3<Float>()
        var rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        (_pxActor as! CPxRigidDynamic).getKinematicTarget(&position, rotation: &rotation)
        (_pxActor as! CPxRigidDynamic).setKinematicTarget(value.internalValue, rotation: rotation)
    }

    func moveRotation(_ value: Quaternion) {
        var position = SIMD3<Float>()
        var rotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
        (_pxActor as! CPxRigidDynamic).getKinematicTarget(&position, rotation: &rotation)
        (_pxActor as! CPxRigidDynamic).setKinematicTarget(position, rotation: value.internalValue)
    }

    func sleep() {
        (_pxActor as! CPxRigidDynamic).putToSleep()
    }

    func wakeUp() {
        (_pxActor as! CPxRigidDynamic).wakeUp()
    }
}
