//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstBendConstraintsBatch: BurstConstraintsBatchImpl, IBendConstraintsBatchImpl {
    private var restBends: [Float] = []
    private var stiffnesses: [float2] = []
    private var plasticity: [float2] = []

    var projectConstraints = BendConstraintsBatchJob()
    var applyConstraints = ApplyBendConstraintsBatchJob()

    public init(constraints: BurstBendConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Bending
    }

    public func SetBendConstraints(particleIndices _: [Int], restBends _: [Float],
                                   bendingStiffnesses _: [Vector2], plasticity _: [Vector2],
                                   lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct BendConstraintsBatchJob {
        public private(set) var particleIndices: [Int] = []
        public private(set) var stiffnesses: [float2] = []
        // plastic yield, creep
        public private(set) var plasticity: [float2] = []
        public var restBends: [Float] = []
        public var lambdas: [Float] = []

        public private(set) var positions: [float4] = []
        public private(set) var invMasses: [Float] = []

        public var deltas: [float4] = []
        public var counts: [Int] = []

        public private(set) var deltaTime: Float = 0

        public func Execute(i _: Int) {}
    }

    public struct ApplyBendConstraintsBatchJob {
        public private(set) var particleIndices: [Int] = []
        public private(set) var sorFactor: Float = 0

        public var positions: [float4] = []
        public var deltas: [float4] = []
        public var counts: [Int] = []

        public func Execute(i _: Int) {}
    }
}
