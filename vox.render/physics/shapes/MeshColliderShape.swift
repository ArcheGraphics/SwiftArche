//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Physical collider shape mesh.
public class MeshColliderShape: ColliderShape {
    public override init() {
        super.init()
        _nativeShape = PhysXPhysics.createPlaneColliderShape(
                _id,
                _material._nativeMaterial
        )
    }
}
