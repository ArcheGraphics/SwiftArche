//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape for capsule.
public class CapsuleColliderShape: ColliderShape {
    /// Radius of capsule.
    @Serialized(default: 1)
    public var radius: Float {
        didSet {
            (_nativeShape as! PhysXCapsuleColliderShape).setRadius(radius)
        }
    }

    /// Height of capsule.
    @Serialized(default: 2)
    public var height: Float {
        didSet {
            (_nativeShape as! PhysXCapsuleColliderShape).setHeight(height)
        }
    }

    /// Up axis of capsule.
    @Serialized(default: .Y)
    public var upAxis: ColliderShapeUpAxis {
        didSet {
            (_nativeShape as! PhysXCapsuleColliderShape).setUpAxis(upAxis.rawValue)
        }
    }

    public required init() {
        super.init()
        _nativeShape = PhysXPhysics.createCapsuleColliderShape(
                _id,
                radius,
                height,
                material._nativeMaterial
        )
    }
}
