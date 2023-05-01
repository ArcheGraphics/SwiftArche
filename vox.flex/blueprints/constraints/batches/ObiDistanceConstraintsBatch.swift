//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiDistanceConstraintsBatch: ObiConstraintsBatch, IStructuralConstraintBatch {
    var m_BatchImpl: IDistanceConstraintsBatchImpl?

    /// Rest distance for each individual constraint.
    public var restLengths: [Float] = []

    /// 2 values for each constraint: compliance and slack.
    public var stiffnesses: [Vector2] = []

    override public init() {
        super.init()
        constraintType = Oni.ConstraintType.Distance
        implementation = m_BatchImpl
    }

    public func GetRestLength(at _: Int) -> Float {
        0
    }

    public func SetRestLength(at _: Int, restLength _: Float) {}

    public func GetParticleIndices(at _: Int) -> ParticlePair {
        ParticlePair(first: 0, second: 0)
    }
}
