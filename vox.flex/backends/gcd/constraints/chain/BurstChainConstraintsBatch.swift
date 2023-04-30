//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstChainConstraintsBatch: BurstConstraintsBatchImpl, IChainConstraintsBatchImpl {
    private var firstIndex: [Int] = []
    private var numIndices: [Int] = []
    private var restLengths: [float2] = []

    public init(constraints: BurstChainConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Chain
    }

    public func SetChainConstraints(particleIndices _: [Int], restLengths _: [Vector2],
                                    firstIndex _: [Int], numIndex _: [Int], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct ChainConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var firstIndex: [Int]
        public private(set) var numIndices: [Int]
        public private(set) var restLengths: [float2]

        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]

        public var deltas: [float4]
        public var counts: [Int]

        public func Execute(c _: Int) {}
    }

    public struct ApplyChainConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var firstIndex: [Int]
        public private(set) var numIndices: [Int]
        public private(set) var sorFactor: Float

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public func Execute(i _: Int) {}
    }
}
