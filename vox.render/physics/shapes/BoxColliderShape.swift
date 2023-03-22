//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape for box.
public class BoxColliderShape: ColliderShape {
    /// Size of box shape.
    @Serialized(default: Vector3(1, 1, 1))
    public var size: Vector3 {
        didSet {
            (_nativeShape as! PhysXBoxColliderShape).setSize(size)
        }
    }

    public required init() {
        super.init()
        _nativeShape = PhysXPhysics.createBoxColliderShape(
                _id,
                size,
                material._nativeMaterial
        )
    }
}
