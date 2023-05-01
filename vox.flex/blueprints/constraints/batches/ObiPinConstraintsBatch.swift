//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiPinConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IPinConstraintsBatchImpl?

    /// for each constraint, handle of the pinned collider.
    public var pinBodies: [ObiColliderHandle] = []

    /// index of the pinned collider in the collider world.
    public var colliderIndices: [Int] = []

    /// Pin position expressed in the attachment's local space.
    public var offsets: [Vector4] = []

    /// Rest Darboux vector for each constraint.
    public var restDarbouxVectors: [Quaternion] = []

    /// Compliances of pin constraits. 2 float per constraint (positional and rotational compliance).
    public var stiffnesses: [Float] = []

    /// One float per constraint: break threshold.
    public var breakThresholds: [Float] = []

    public init(constraints _: ObiPinConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Pin
        implementation = m_BatchImpl
    }
}
