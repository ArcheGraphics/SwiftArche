//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstStitchConstraintsBatch: BurstConstraintsBatchImpl, IStitchConstraintsBatchImpl {
    private var stiffnesses: [Float] = []

    public init(constraints: BurstStitchConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Stitch
    }

    public func SetStitchConstraints(particleIndices _: [Int], stiffnesses _: [Float],
                                     lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct StitchConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var stiffnesses: [Float]
        public var lambdas: [Float]

        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]

        public var deltas: [float4]
        public var counts: [Int]

        public private(set) var deltaTimeSqr: Float
        public private(set) var activeConstraintCount: Int

        public func Execute() {}
    }

    public struct ApplyStitchConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var sorFactor: Float

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public private(set) var activeConstraintCount: Int

        public func Execute() {}
    }
}
