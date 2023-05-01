//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstSkinConstraintsBatch: BurstConstraintsBatchImpl, ISkinConstraintsBatchImpl {
    private var skinPoints: [float4] = []
    private var skinNormals: [float4] = []
    private var skinRadiiBackstop: [Float] = []
    private var skinCompliance: [Float] = []

    public init(constraints: BurstSkinConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Skin
    }

    public func SetSkinConstraints(particleIndices _: [Int], skinPoints _: [Vector4],
                                   skinNormals _: [Vector4], skinRadiiBackstop _: [Float],
                                   skinCompliance _: [Float], lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct SkinConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var skinPoints: [float4]
        public private(set) var skinNormals: [float4]
        public private(set) var skinRadiiBackstop: [float3]
        public private(set) var skinCompliance: [Float]
        public var lambdas: [Float]

        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]

        public var deltas: [float4]
        public var counts: [Int]

        public private(set) var deltaTimeSqr: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplySkinConstraintsBatchJob {
        private(set) var particleIndices: [Int]
        public private(set) var sorFactor: Float

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public func Execute(i _: Int) {}
    }
}
