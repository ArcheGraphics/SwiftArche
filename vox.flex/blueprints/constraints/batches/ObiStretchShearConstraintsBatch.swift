//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiStretchShearConstraintsBatch: ObiConstraintsBatch, IStructuralConstraintBatch {
    var m_BatchImpl: IStretchShearConstraintsBatchImpl?

    /// index of particle orientation for each constraint.
    public var orientationIndices: [Int] = []

    /// rest distance for each constraint.
    public var restLengths: [Float] = []

    /// rest orientation for each constraint.
    public var restOrientations: [Quaternion] = []

    /// 3 compliance values per constraint, one for each local axis (x,y,z).
    public var stiffnesses: [Vector3] = []

    public init(constraints _: ObiStretchShearConstraintsData? = nil) {
        super.init()
        constraintType = Oni.ConstraintType.StretchShear
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
