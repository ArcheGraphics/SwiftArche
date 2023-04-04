//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A dynamic collider can act with self-defined movement or physical force.
public class DynamicCollider: Collider {
    private var _density: Float = 1

    /// The linear damping of the dynamic collider.
    @Serialized(default: 0)
    public var linearDamping: Float {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setLinearDamping(linearDamping)
        }
    }

    /// The angular damping of the dynamic collider.
    @Serialized(default: 0.05)
    public var angularDamping: Float {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setAngularDamping(angularDamping)
        }
    }

    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    @Serialized(default: Vector3())
    public var linearVelocity: Vector3 {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setLinearVelocity(linearVelocity)
        }
    }

    /// The angular velocity vector of the dynamic collider measured in radians per second.
    @Serialized(default: Vector3())
    public var angularVelocity: Vector3 {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setAngularVelocity(angularVelocity)
        }
    }

    /// The center of mass relative to the transform's origin.
    @Serialized(default: Vector3())
    public var centerOfMass: Vector3 {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setCenterOfMass(centerOfMass)
        }
    }

    /// The diagonal inertia tensor of mass relative to the center of mass.
    @Serialized(default: Vector3(1, 1, 1))
    public var inertiaTensor: Vector3 {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setInertiaTensor(inertiaTensor)
        }
    }

    /// The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
    @Serialized(default: 100)
    public var maxAngularVelocity: Float {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setMaxAngularVelocity(maxAngularVelocity)
        }
    }

    /// Maximum velocity of a collider when moving out of penetrating state.
    @Serialized(default: 1000)
    public var maxDepenetrationVelocity: Float {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setMaxDepenetrationVelocity(maxDepenetrationVelocity)
        }
    }

    /// The mass-normalized energy threshold, below which objects start going to sleep.
    @Serialized(default: 5e-3)
    public var sleepThreshold: Float {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setSleepThreshold(sleepThreshold)
        }
    }

    /// The solverIterations determines how accurately collider joints and collision contacts are resolved.
    @Serialized(default: 4)
    public var solverIterations: Int {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setSolverIterations(solverIterations)
        }
    }

    /// Controls whether physics affects the dynamic collider.
    @Serialized(default: false)
    public var isKinematic: Bool {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setIsKinematic(isKinematic)
        }
    }

    /// The colliders' collision detection mode.
    @Serialized(default: .Discrete)
    public var collisionDetectionMode: CollisionDetectionMode {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setCollisionDetectionMode(collisionDetectionMode)
        }
    }

    /// The particular rigid dynamic lock flag.
    @Serialized(default: [])
    public var constraints: DynamicColliderConstraints {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setConstraints(constraints)
        }
    }

    @Serialized(default: true)
    public var useGravity: Bool {
        didSet {
            (_nativeCollider as! PhysXDynamicCollider).setUseGravity(useGravity)
        }
    }

    /// The mass of the dynamic collider.
    public var mass: Float {
        get {
            (_nativeCollider as! PhysXDynamicCollider).getMass()
        }
        set {
            (_nativeCollider as! PhysXDynamicCollider).setMass(newValue)
        }
    }

    override public internal(set) var entity: Entity {
        get {
            _entity
        }
        set {
            super.entity = newValue
            let transform = _entity.transform!
            _nativeCollider = PhysXPhysics.createDynamicCollider(
                transform.worldPosition,
                transform.worldRotationQuaternion
            )
        }
    }

    /// Apply a force to the DynamicCollider.
    /// - Parameter force: The force make the collider move
    public func applyForce(_ force: Vector3) {
        (_nativeCollider as! PhysXDynamicCollider).addForce(force)
    }

    /// Apply a torque to the DynamicCollider.
    /// - Parameter torque: The force make the collider rotate
    public func applyTorque(_ torque: Vector3) {
        (_nativeCollider as! PhysXDynamicCollider).addTorque(torque)
    }

    /// Applies force at position. As a result this will apply a torque and force on the object.
    public func applyForceAtPosition(_ force: Vector3, _ pos: Vector3, mode: ForceMode = .Force) {
        (_nativeCollider as! PhysXDynamicCollider).addForceAtPosition(force, pos, mode)
    }

    /// Moves the kinematic collider towards position.
    public func movePosition(_ value: Vector3) {
        (_nativeCollider as! PhysXDynamicCollider).movePosition(value)
    }

    /// Rotates the collider to rotation.
    public func moveRotation(_ value: Quaternion) {
        (_nativeCollider as! PhysXDynamicCollider).moveRotation(value)
    }

    /// Forces a collider to sleep at least one frame.
    public func sleep() {
        (_nativeCollider as! PhysXDynamicCollider).sleep()
    }

    /// Forces a collider to wake up.
    public func wakeUp() {
        (_nativeCollider as! PhysXDynamicCollider).wakeUp()
    }

    /// Sets the mass based on the attached colliders assuming a constant density.
    public func setDensity(_ value: Float) {
        _density = value
        (_nativeCollider as! PhysXDynamicCollider).setDensity(value)
    }

    override public func addShape(_ shape: ColliderShape) {
        super.addShape(shape)
        setDensity(_density)
    }

    override func _onLateUpdate() {
        let transform = entity.transform!
        _nativeCollider.getWorldTransform(&transform.worldPosition, &transform.worldRotationQuaternion)
        _updateFlag.flag = false
    }
}
