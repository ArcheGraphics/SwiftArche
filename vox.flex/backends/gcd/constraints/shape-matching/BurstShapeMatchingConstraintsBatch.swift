//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstShapeMatchingConstraintsBatch: BurstConstraintsBatchImpl, IShapeMatchingConstraintsBatchImpl
{
    private var firstIndex: [Int] = []
    private var numIndices: [Int] = []
    private var explicitGroup: [Int] = []
    private var shapeMaterialParameters: [Float] = []
    private var restComs: [float4] = []
    private var coms: [float4] = []
    private var constraintOrientations: [quaternion] = []

    private var Aqq: [float4x4] = []
    private var linearTransforms: [float4x4] = []
    private var plasticDeformations: [float4x4] = []

    public init(constraints: BurstShapeMatchingConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.ShapeMatching
    }

    public func SetShapeMatchingConstraints(particleIndices _: [Int], firstIndex _: [Int],
                                            numIndices _: [Int], explicitGroup _: [Int], shapeMaterialParameters _: [Float],
                                            restComs _: [Vector4], coms _: [Vector4], orientations _: [Quaternion],
                                            linearTransforms _: [Matrix], plasticDeformations _: [Matrix],
                                            lambdas _: [Float], count _: Int) {}

    public func CalculateRestShapeMatching() {}

    override public func Initialize(substepTime _: Float) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    static func RecalculateRestData(i _: Int,
                                    particleIndices _: [Int],
                                    firstIndex _: [Int],
                                    restComs _: [float4],
                                    Aqq _: [float4x4],
                                    deformation _: [float4x4],
                                    numIndices _: [Int],
                                    invMasses _: [Float],
                                    restPositions _: [float4],
                                    restOrientations _: [quaternion],
                                    invInertiaTensors _: [float4]) {}

    public struct ShapeMatchingCalculateRestJob {
        public private(set) var particleIndices: [Int]
        public private(set) var firstIndex: [Int]
        public private(set) var numIndices: [Int]
        public var restComs: [float4]
        public private(set) var coms: [float4]

        public var Aqq: [float4x4]
        public private(set) var deformation: [float4x4]

        public private(set) var restPositions: [float4]
        public private(set) var restOrientations: [quaternion]
        public private(set) var invMasses: [Float]
        public private(set) var invInertiaTensors: [float4]

        public func Execute(i _: Int) {}
    }

    public struct ShapeMatchingConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var firstIndex: [Int]
        public private(set) var numIndices: [Int]
        public private(set) var explicitGroup: [Int]
        public private(set) var shapeMaterialParameters: [Float]
        public var restComs: [float4]
        public var coms: [float4]
        public var constraintOrientations: [quaternion]

        public var Aqq: [float4x4]
        public var linearTransforms: [float4x4]
        public var deformation: [float4x4]

        public private(set) var positions: [float4]
        public private(set) var restPositions: [float4]

        public private(set) var restOrientations: [quaternion]
        public private(set) var invMasses: [Float]
        public private(set) var invRotationalMasses: [Float]
        public private(set) var invInertiaTensors: [float4]

        public var orientations: [quaternion]
        public var deltas: [float4]
        public var counts: [Int]

        public var deltaTime: Float

        public func Execute(i _: Int) {}
    }

    public struct ApplyShapeMatchingConstraintsBatchJob {
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
