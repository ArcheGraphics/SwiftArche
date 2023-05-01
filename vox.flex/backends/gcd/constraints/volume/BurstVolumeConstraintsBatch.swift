//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstVolumeConstraintsBatch: BurstConstraintsBatchImpl, IVolumeConstraintsBatchImpl {
    private var firstTriangle: [Int] = []
    private var numTriangles: [Int] = []
    private var restVolumes: [Float] = []
    private var pressureStiffness: [float2] = []

    public init(constraints: BurstVolumeConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Volume
    }

    public func SetVolumeConstraints(triangles _: [Int], firstTriangle _: [Int], numTriangles _: [Int],
                                     restVolumes _: [Float], pressureStiffness _: [Vector2], lambdas _: [Float], count _: Int) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct VolumeConstraintsBatchJob {
        public private(set) var triangles: [Int]
        public private(set) var firstTriangle: [Int]
        public private(set) var numTriangles: [Int]
        public private(set) var restVolumes: [Float]
        public private(set) var pressureStiffness: [float2]
        public var lambdas: [Float]

        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]

        public var gradients: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public var deltaTimeSqr: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplyVolumeConstraintsBatchJob {
        public private(set) var triangles: [Int]
        public private(set) var firstTriangle: [Int]
        public private(set) var numTriangles: [Int]
        public private(set) var sorFactor: Float

        public var positions: [float4]
        public var deltas: [float4]
        public var counts: [Int]

        public func Execute(i _: Int) {}
    }
}
