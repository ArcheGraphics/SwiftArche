//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// A static collider component that will not move.
/// - Remark: Mostly used for object which always stays at the same place and never moves around.
public class StaticCollider: Collider {
    public required init(_ entity: Entity) {
        super.init(entity)
        let transform = entity.transform
        _nativeCollider = PhysXPhysics.createStaticCollider(
                transform!.worldPosition,
                transform!.worldRotationQuaternion
        )
    }
}
