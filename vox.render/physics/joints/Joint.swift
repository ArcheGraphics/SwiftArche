//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

///  A base class providing common functionality for joints.
public class Joint: Component {
    private static var _idGenerator: UInt32 = 0

    var _connectedCollider = JointCollider()
    var _collider = JointCollider()
    var _nativeJoint: PhysXJoint!
    private var _force: Float = 0
    private var _torque: Float = 0
    private var _name: String

    /// The connected collider.
    public var connectedCollider: Collider? {
        get {
            _connectedCollider.collider
        }
        set {
            if (_connectedCollider.collider !== newValue) {
                _connectedCollider.collider = newValue
                _nativeJoint.setConnectedCollider(newValue!._nativeCollider)
            }
        }
    }

    /// The connected anchor position.
    /// - Remark: If connectedCollider is set, this anchor is relative offset, or the anchor is world position.
    public var connectedAnchor: Vector3 {
        get {
            _connectedCollider.localPosition!
        }
        set {
            _connectedCollider.localPosition = newValue
            _nativeJoint.setConnectedAnchor(newValue)
        }
    }

    /// The scale to apply to the inverse mass of collider 0 for resolving this constraint.
    public var connectedMassScale: Float {
        get {
            _connectedCollider.massScale
        }
        set {
            if (newValue != _connectedCollider.massScale) {
                _connectedCollider.massScale = newValue
                _nativeJoint.setConnectedMassScale(newValue)
            }
        }
    }

    /// The scale to apply to the inverse inertia of collider0 for resolving this constraint.
    public var connectedInertiaScale: Float {
        get {
            _connectedCollider.inertiaScale
        }
        set {
            if (newValue != _connectedCollider.inertiaScale) {
                _connectedCollider.inertiaScale = newValue
                _nativeJoint.setConnectedInertiaScale(newValue)
            }
        }
    }

    /// The scale to apply to the inverse mass of collider 1 for resolving this constraint.
    public var massScale: Float {
        get {
            _collider.massScale
        }
        set {
            if (newValue != _collider.massScale) {
                _collider.massScale = newValue
                _nativeJoint.setMassScale(newValue)
            }
        }
    }

    /// The scale to apply to the inverse inertia of collider1 for resolving this constraint.
    public var inertiaScale: Float {
        get {
            _collider.inertiaScale
        }
        set {
            if (newValue != _collider.inertiaScale) {
                _collider.inertiaScale = newValue
                _nativeJoint.setInertiaScale(newValue)
            }
        }
    }

    /// The maximum force the joint can apply before breaking.
    public var breakForce: Float {
        get {
            _force
        }
        set {
            if (newValue != _force) {
                _force = newValue
                _nativeJoint.setBreakForce(newValue)
            }
        }
    }

    /// The maximum torque the joint can apply before breaking.
    public var breakTorque: Float {
        get {
            _torque
        }
        set {
            if (newValue != _torque) {
                _torque = newValue
                _nativeJoint.setBreakTorque(newValue)
            }
        }
    }

    var name: String {
        _name
    }

    required init(_ entity: Entity) {
        _name = "joint\(Joint._idGenerator)"
        Joint._idGenerator += 1

        _connectedCollider.localPosition = Vector3()
        super.init(entity)
    }
}

struct JointCollider {
    var collider: Collider? = nil
    var localPosition: Vector3?
    var localRotation: Quaternion?
    var massScale: Float = 0
    var inertiaScale: Float = 0
}
