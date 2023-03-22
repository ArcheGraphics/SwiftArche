//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape for sphere.
public class SphereColliderShape: ColliderShape {
    /// Radius of sphere shape.
    @Serialized(default: 1)
    public var radius: Float {
        didSet {
            (_nativeShape as! PhysXSphereColliderShape).setRadius(radius)
        }
    }

    public required init() {
        super.init()
        _nativeShape = PhysXPhysics.createSphereColliderShape(
                _id,
                radius,
                material._nativeMaterial
        )
    }
}
