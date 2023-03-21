//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A joint which behaves in a similar way to a hinge or axle.
public class HingeJoint: Joint {
    private var _axis: Vector3 = Vector3(1, 0, 0)
    private var _hingeFlags: UInt32 = 0
    private var _useSpring: Bool = false
    private var _jointMonitor: JointMotor?
    private var _limits: JointLimits?

    /// The anchor rotation.
    public var axis: Vector3 {
        get {
            _axis
        }
        set {
            _axis = newValue
            (_nativeJoint as! PhysXHingeJoint).setAxis(newValue)
        }
    }

    /// The swing offset.
    public var swingOffset: Vector3 {
        get {
            _collider.localPosition!
        }
        set {
            _collider.localPosition = newValue
            (_nativeJoint as! PhysXHingeJoint).setSwingOffset(newValue)
        }
    }

    /// The current angle in degrees of the joint relative to its rest position.
    public var angle: Float {
        get {
            (_nativeJoint as! PhysXHingeJoint).getAngle()
        }
    }

    /// The angular velocity of the joint in degrees per second.
    public var velocity: Vector3 {
        get {
            (_nativeJoint as! PhysXHingeJoint).getVelocity()
        }
    }

    /// Enables the joint's limits. Disabled by default.
    public var useLimits: Bool {
        get {
            (_hingeFlags & HingeJointFlag.LimitEnabled.rawValue) == HingeJointFlag.LimitEnabled.rawValue
        }
        set {
            if (newValue != useLimits) {
                _hingeFlags |= HingeJointFlag.LimitEnabled.rawValue
            }
            (_nativeJoint as! PhysXHingeJoint).setHingeJointFlag(HingeJointFlag.LimitEnabled.rawValue, newValue)
        }
    }

    /// Enables the joint's motor. Disabled by default.
    public var useMotor: Bool {
        get {
            (_hingeFlags & HingeJointFlag.DriveEnabled.rawValue) == HingeJointFlag.DriveEnabled.rawValue
        }
        set {
            if (newValue != useMotor) {
                _hingeFlags |= HingeJointFlag.DriveEnabled.rawValue
            }
            (_nativeJoint as! PhysXHingeJoint).setHingeJointFlag(HingeJointFlag.DriveEnabled.rawValue, newValue)
        }
    }

    /// Enables the joint's spring. Disabled by default.
    public var useSpring: Bool {
        get {
            _useSpring
        }
        set {
            _useSpring = newValue
            limits = _limits
        }
    }

    /// The motor will apply a force up to a maximum force to achieve the target velocity in degrees per second.
    public var motor: JointMotor? {
        get {
            _jointMonitor
        }
        set {
            _jointMonitor = newValue
            if newValue != nil {
                (_nativeJoint as! PhysXHingeJoint).setDriveVelocity(newValue!.targetVelocity)
                (_nativeJoint as! PhysXHingeJoint).setDriveForceLimit(newValue!.forceLimit)
                (_nativeJoint as! PhysXHingeJoint).setDriveGearRatio(newValue!.gearRation)
                (_nativeJoint as! PhysXHingeJoint).setHingeJointFlag(HingeJointFlag.DriveFreeSpin.rawValue, newValue!.freeSpin)
            }
        }
    }

    /// Limit of angular rotation (in degrees) on the hinge joint.
    public var limits: JointLimits? {
        get {
            _limits
        }
        set {
            _limits = newValue
            if newValue != nil {
                if (useSpring) {
                    (_nativeJoint as! PhysXHingeJoint).setSoftLimit(newValue!.min, newValue!.max, newValue!.stiffness, newValue!.damping)
                } else {
                    (_nativeJoint as! PhysXHingeJoint).setHardLimit(newValue!.min, newValue!.max, newValue!.contactDistance)
                }
            }
        }
    }

    override func _onAwake() {
        _collider.localPosition = Vector3()
        _collider.collider = entity.getComponent(Collider.self)
        _nativeJoint = PhysXPhysics.createHingeJoint(_collider.collider!._nativeCollider)
        _nativeJoint.setName(name)
    }
    
    required init(_ engine: Engine) {
        super.init(engine)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
    }
}
