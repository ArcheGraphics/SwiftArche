//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiChainConstraintsBatch: ObiConstraintsBatch {
    var m_BatchImpl: IChainConstraintsBatchImpl?

    /// index of the first particle for each constraint.
    public var firstParticle: [Int] = []

    /// number of particles for each constraint.
    public var numParticles: [Int] = []

    /// min/max lenghts for each constraint.
    public var lengths: [Vector2] = []

    public init(constraints _: ObiChainConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.Chain
        implementation = m_BatchImpl
    }
}
