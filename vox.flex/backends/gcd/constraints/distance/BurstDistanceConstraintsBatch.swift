//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstDistanceConstraintsBatch: BurstConstraintsBatchImpl, IDistanceConstraintsBatchImpl
{
    private var restLengths: [Float] = []
    private var stiffnesses: [float2] = []

    var projectConstraints = DistanceConstraintsBatchJob()
    var applyConstraints = ApplyDistanceConstraintsBatchJob()

    public init(constraints: BurstDistanceConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Distance
    }

    public func SetDistanceConstraints(particleIndices _: [Int], restLengths _: [Float],
                                       stiffnesses _: [Vector2], lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct DistanceConstraintsBatchJob {
        public private(set) var particleIndices: [Int] = []
        public private(set) var restLengths: [Float] = []
        public private(set) var stiffnesses: [float2] = []
        public var lambdas: [Float] = []

        public private(set) var positions: [float4] = []
        public private(set) var invMasses: [Float] = []

        public var deltas: [float4] = []
        public var counts: [Int] = []

        public private(set) var deltaTimeSqr: Float = 0

        public func Execute(i _: Int) {}
    }

    public struct ApplyDistanceConstraintsBatchJob {
        public private(set) var particleIndices: [Int] = []
        public private(set) var sorFactor: Float = 0

        public var positions: [float4] = []
        public var deltas: [float4] = []
        public var counts: [Int] = []

        public func Execute(i _: Int) {}
    }
}
