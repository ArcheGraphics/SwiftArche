//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A static collider component that will not move.
/// - Remark: Mostly used for object which always stays at the same place and never moves around.
class PhysXStaticCollider: PhysXCollider {
    /// Initialize PhysX static actor.
    /// - Parameters:
    ///   - position: The global position
    ///   - rotation: The global rotation
    init(_ position: Vector3, _ rotation: Quaternion) {
        super.init()
        _pxActor = PhysXPhysics._pxPhysics.createRigidStatic(withPosition: position.internalValue,
                                                             rotation: rotation.normalized.internalValue)
    }
}
