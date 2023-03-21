//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A dynamic collider can act with self-defined movement or physical force.
public class DynamicCollider: Collider {
    private var _linearDamping: Float = 0
    private var _angularDamping: Float = 0.05
    private var _linearVelocity = Vector3()
    private var _angularVelocity = Vector3()
    private var _centerOfMass = Vector3()
    private var _inertiaTensor = Vector3(1, 1, 1)
    private var _maxAngularVelocity: Float = 100
    private var _maxDepenetrationVelocity: Float = 1000
    private var _solverIterations: Int = 4
    private var _isKinematic: Bool = false
    private var _constraints: DynamicColliderConstraints = []
    private var _collisionDetectionMode: CollisionDetectionMode = .Discrete
    private var _sleepThreshold: Float = 5e-3
    private var _useGravity: Bool = true
    private var _density: Float = 1

    /// The linear damping of the dynamic collider.
    public var linearDamping: Float {
        get {
            _linearDamping
        }
        set {
            if _linearDamping != newValue {
                _linearDamping = newValue
                (_nativeCollider as! PhysXDynamicCollider).setLinearDamping(newValue)
            }
        }
    }

    /// The angular damping of the dynamic collider.
    public var angularDamping: Float {
        get {
            _angularDamping
        }
        set {
            if _angularDamping != newValue {
                _angularDamping = newValue
                (_nativeCollider as! PhysXDynamicCollider).setAngularDamping(newValue)
            }
        }
    }

    /// The linear velocity vector of the dynamic collider measured in world unit per second.
    public var linearVelocity: Vector3 {
        get {
            _linearVelocity
        }
        set {
            _linearVelocity = newValue
            (_nativeCollider as! PhysXDynamicCollider).setLinearVelocity(_linearVelocity)
        }
    }

    /// The angular velocity vector of the dynamic collider measured in radians per second.
    public var angularVelocity: Vector3 {
        get {
            _angularVelocity
        }
        set {
            _angularVelocity = newValue
            (_nativeCollider as! PhysXDynamicCollider).setAngularVelocity(_angularVelocity)
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

    /// The center of mass relative to the transform's origin.
    public var centerOfMass: Vector3 {
        get {
            _centerOfMass
        }
        set {
            _centerOfMass = newValue
            (_nativeCollider as! PhysXDynamicCollider).setCenterOfMass(_centerOfMass)
        }
    }

    /// The diagonal inertia tensor of mass relative to the center of mass.
    public var inertiaTensor: Vector3 {
        get {
            _inertiaTensor
        }
        set {
            _inertiaTensor = newValue
            (_nativeCollider as! PhysXDynamicCollider).setInertiaTensor(_inertiaTensor)
        }
    }

    /// The maximum angular velocity of the collider measured in radians per second. (Default 7) range { 0, infinity }.
    public var maxAngularVelocity: Float {
        get {
            _maxAngularVelocity
        }
        set {
            if _maxAngularVelocity != newValue {
                _maxAngularVelocity = newValue
                (_nativeCollider as! PhysXDynamicCollider).setMaxAngularVelocity(newValue)
            }
        }
    }

    /// Maximum velocity of a collider when moving out of penetrating state.
    public var maxDepenetrationVelocity: Float {
        get {
            _maxDepenetrationVelocity
        }
        set {
            if _maxDepenetrationVelocity != newValue {
                _maxDepenetrationVelocity = newValue
                (_nativeCollider as! PhysXDynamicCollider).setMaxDepenetrationVelocity(newValue)
            }
        }
    }

    /// The mass-normalized energy threshold, below which objects start going to sleep.
    public var sleepThreshold: Float {
        get {
            _sleepThreshold
        }
        set {
            if _sleepThreshold != newValue {
                _sleepThreshold = newValue
                (_nativeCollider as! PhysXDynamicCollider).setSleepThreshold(newValue)
            }
        }
    }

    /// The solverIterations determines how accurately collider joints and collision contacts are resolved.
    public var solverIterations: Int {
        get {
            _solverIterations
        }
        set {
            if _solverIterations != newValue {
                _solverIterations = newValue
                (_nativeCollider as! PhysXDynamicCollider).setSolverIterations(newValue)
            }
        }
    }

    /// Controls whether physics affects the dynamic collider.
    public var isKinematic: Bool {
        get {
            _isKinematic
        }
        set {
            if _isKinematic != newValue {
                _isKinematic = newValue
                (_nativeCollider as! PhysXDynamicCollider).setIsKinematic(newValue)
            }
        }
    }

    /// The colliders' collision detection mode.
    public var collisionDetectionMode: CollisionDetectionMode {
        get {
            _collisionDetectionMode
        }
        set {
            if _collisionDetectionMode != newValue {
                _collisionDetectionMode = newValue
                (_nativeCollider as! PhysXDynamicCollider).setCollisionDetectionMode(newValue)
            }
        }
    }

    /// The particular rigid dynamic lock flag.
    public var constraints: DynamicColliderConstraints {
        get {
            _constraints
        }
        set {
            if (_constraints != newValue) {
                _constraints = newValue
                (_nativeCollider as! PhysXDynamicCollider).setConstraints(newValue)
            }
        }
    }

    public var useGravity: Bool {
        get {
            _useGravity
        }
        set {
            if _useGravity != newValue {
                _useGravity = newValue
                (_nativeCollider as! PhysXDynamicCollider).setUseGravity(newValue)
            }
        }
    }
    
    public internal(set) override var entity: Entity {
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
    
    public override func addShape(_ shape: ColliderShape) {
        super.addShape(shape)
        setDensity(_density)
    }

    override func _onLateUpdate() {
        let transform = entity.transform!
        _nativeCollider.getWorldTransform(&transform.worldPosition, &transform.worldRotationQuaternion)
        _updateFlag.flag = false
    }
}
