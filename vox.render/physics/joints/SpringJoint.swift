//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A joint that maintains an upper or lower bound (or both) on the distance between two points on different objects.
public class SpringJoint: Joint {
    private var _minDistance: Float = 0
    private var _maxDistance: Float = 0
    private var _tolerance: Float = 0.25
    private var _stiffness: Float = 0
    private var _damping: Float = 0

    /// The swing offset.
    public var swingOffset: Vector3 {
        get {
            _collider.localPosition!
        }
        set {
            _collider.localPosition = newValue
            (_nativeJoint as! PhysXSpringJoint).setSwingOffset(newValue)
        }
    }

    /// The minimum distance.
    public var minDistance: Float {
        get {
            _minDistance
        }
        set {
            _minDistance = newValue
            (_nativeJoint as! PhysXSpringJoint).setMinDistance(newValue)
        }
    }

    /// The maximum distance.
    public var maxDistance: Float {
        get {
            _maxDistance
        }
        set {
            _maxDistance = newValue
            (_nativeJoint as! PhysXSpringJoint).setMaxDistance(newValue)
        }
    }

    /// The distance beyond the allowed range at which the joint becomes active.
    public var tolerance: Float {
        get {
            _tolerance
        }
        set {
            _tolerance = newValue
            (_nativeJoint as! PhysXSpringJoint).setTolerance(newValue)
        }
    }

    /// The spring strength of the joint.
    public var stiffness: Float {
        get {
            _stiffness
        }
        set {
            _stiffness = newValue
            (_nativeJoint as! PhysXSpringJoint).setStiffness(newValue)
        }
    }

    /// The degree of damping of the joint spring of the joint.
    public var damping: Float {
        get {
            _damping
        }
        set {
            _damping = newValue
            (_nativeJoint as! PhysXSpringJoint).setDamping(newValue)
        }
    }

    override func _onAwake() {
        _collider.localPosition = Vector3()
        _collider.collider = entity.getComponent(Collider.self)
        _nativeJoint = PhysXPhysics.createSpringJoint(_collider.collider!._nativeCollider)
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
