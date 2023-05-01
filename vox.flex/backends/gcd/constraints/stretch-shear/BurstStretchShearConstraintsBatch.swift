//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstStretchShearConstraintsBatch: BurstConstraintsBatchImpl, IStretchShearConstraintsBatchImpl
{
    private var orientationIndices: [Int] = []
    private var restLengths: [Float] = []
    private var restOrientations: [quaternion] = []
    private var stiffnesses: [float3] = []

    public init(constraints: BurstStretchShearConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.StretchShear
    }

    public func SetStretchShearConstraints(particleIndices _: [Int], orientationIndices _: [Int],
                                           restLengths _: [Float], restOrientations _: [Quaternion],
                                           stiffnesses _: [Vector3], lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct StretchShearConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var orientationIndices: [Int]
        public private(set) var restLengths: [Float]
        public private(set) var restOrientations: [quaternion]
        public private(set) var stiffnesses: [float3]
        public var lambdas: [float3]

        public private(set) var positions: [float4]
        public private(set) var orientations: [quaternion]
        public private(set) var invMasses: [Float]
        public private(set) var invRotationalMasses: [Float]

        public var deltas: [float4]
        public var orientationDeltas: [quaternion]
        public var counts: [Int]
        public var orientationCounts: [Int]

        public private(set) var deltaTimeSqr: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplyStretchShearConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var orientationIndices: [Int]
        public private(set) var sorFactor: Float

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public var orientations: [quaternion]
        public var orientationDeltas: [quaternion]
        public var orientationCounts: [Int]

        public func Execute(i _: Int) {}
    }
}
