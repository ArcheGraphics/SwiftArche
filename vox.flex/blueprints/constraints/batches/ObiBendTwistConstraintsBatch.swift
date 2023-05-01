//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiBendTwistConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IBendTwistConstraintsBatchImpl?

    /// Rest darboux vector for each constraint.
    public var restDarbouxVectors: [Quaternion] = []

    /// 3 compliance values for each constraint, one for each local axis (x,y,z)
    public var stiffnesses: [Vector3] = []

    /// two floats per constraint: plastic yield and creep.
    public var plasticity: [Vector2] = []

    public init(constraints _: ObiBendTwistConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.BendTwist
        implementation = m_BatchImpl
    }
}
