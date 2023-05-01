//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstTetherConstraintsBatch: BurstConstraintsBatchImpl, ITetherConstraintsBatchImpl {
    private var maxLengthScale: [float2] = []
    private var stiffnesses: [Float] = []

    public init(constraints: BurstTetherConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Tether
    }

    public func SetTetherConstraints(particleIndices _: [Int], maxLengthScale _: [Vector2],
                                     stiffnesses _: [Float], lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct TetherConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var maxLengthScale: [float2]
        public private(set) var stiffnesses: [Float]
        public var lambdas: [Float]

        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]

        public var deltas: [float4]
        public var counts: [Int]

        public private(set) var deltaTimeSqr: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplyTetherConstraintsBatchJob {
        public private(set) var particleIndices: [Int]

        // linear/position properties:
        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public private(set) var sorFactor: Float

        public func Execute(index _: Int) {}
    }
}
