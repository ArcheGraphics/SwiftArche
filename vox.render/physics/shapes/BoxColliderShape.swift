//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Physical collider shape for box.
public class BoxColliderShape: ColliderShape {
    private var _size: Vector3 = Vector3(1, 1, 1)

    /// Size of box shape.
    public var size: Vector3 {
        get {
            _size
        }
        set {
            _size = newValue
            (_nativeShape as! PhysXBoxColliderShape).setSize(newValue)
        }
    }

    public override init() {
        super.init()
        _nativeShape = PhysXPhysics.createBoxColliderShape(
                _id,
                _size,
                _material._nativeMaterial
        )
    }
}
