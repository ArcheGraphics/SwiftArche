//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Physical collider shape for sphere.
public class SphereColliderShape: ColliderShape {
    private var _radius: Float = 1

    /// Radius of sphere shape.
    public var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            (_nativeShape as! PhysXSphereColliderShape).setRadius(newValue)
        }
    }

    public override init() {
        super.init()
        _nativeShape = PhysXPhysics.createSphereColliderShape(
                _id,
                _radius,
                _material._nativeMaterial
        )
    }
}
