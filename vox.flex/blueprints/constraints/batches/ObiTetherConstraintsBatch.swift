//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiTetherConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: ITetherConstraintsBatchImpl?

    /// 2 floats per constraint: maximum length and tether scale.
    public var maxLengthsScales: [Vector2] = []

    /// compliance value for each constraint.
    public var stiffnesses: [Float] = []

    public init(constraints _: ObiTetherConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Tether
        implementation = m_BatchImpl
    }
}
