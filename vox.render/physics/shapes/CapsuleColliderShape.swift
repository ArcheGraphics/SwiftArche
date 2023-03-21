//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape for capsule.
public class CapsuleColliderShape: ColliderShape {
    private var _radius: Float = 1
    private var _height: Float = 2
    private var _upAxis: ColliderShapeUpAxis = ColliderShapeUpAxis.Y

    /// Radius of capsule.
    public var radius: Float {
        get {
            _radius
        }
        set {
            (_nativeShape as! PhysXCapsuleColliderShape).setRadius(newValue)
        }
    }

    /// Height of capsule.
    public var height: Float {
        get {
            _height
        }
        set {
            (_nativeShape as! PhysXCapsuleColliderShape).setHeight(newValue)
        }
    }

    /// Up axis of capsule.
    public var upAxis: ColliderShapeUpAxis {
        get {
            _upAxis
        }
        set {
            (_nativeShape as! PhysXCapsuleColliderShape).setUpAxis(newValue.rawValue)
        }
    }

    public required init() {
        super.init()
        _nativeShape = PhysXPhysics.createCapsuleColliderShape(
                _id,
                _radius,
                _height,
                _material._nativeMaterial
        )
    }
}
