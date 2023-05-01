//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiBendConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IBendConstraintsBatchImpl?

    /// one float per constraint: the rest bend distance.
    public var restBends: [Float] = []

    /// two floats per constraint: max bending and compliance.
    public var bendingStiffnesses: [Vector2] = []

    /// two floats per constraint: plastic yield and creep.
    public var plasticity: [Vector2] = []

    public init(constraints _: ObiBendConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Bending
        implementation = m_BatchImpl
    }
}
