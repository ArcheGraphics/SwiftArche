//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstBendTwistConstraintsBatch: BurstConstraintsBatchImpl, IBendTwistConstraintsBatchImpl
{
    private var orientationIndices: [Int] = []
    private var restDarboux: [quaternion] = []
    private var stiffnesses: [float3] = []
    private var plasticity: [float2] = []

    public init(constraints: BurstBendTwistConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.BendTwist
    }

    public func SetBendTwistConstraints(orientationIndices _: [Int], restDarboux _: [Quaternion],
                                        stiffnesses _: [Vector3], plasticity _: [Vector2],
                                        lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct BendTwistConstraintsBatchJob {
        public private(set) var orientationIndices: [Int]
        public private(set) var stiffnesses: [float3]
        public private(set) var plasticity: [float2]
        public var restDarboux: [quaternion]
        public var lambdas: [float3]

        public private(set) var orientations: [quaternion]
        public private(set) var invRotationalMasses: [Float]

        public var orientationDeltas: [quaternion]
        public var orientationCounts: [Int]

        public private(set) var deltaTime: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplyBendTwistConstraintsBatchJob {
        public private(set) var orientationIndices: [Int]
        public private(set) var sorFactor: Float

        public var orientations: [quaternion]
        public var orientationDeltas: [quaternion]
        public var orientationCounts: [Int]

        public func Execute(i _: Int) {}
    }
}
