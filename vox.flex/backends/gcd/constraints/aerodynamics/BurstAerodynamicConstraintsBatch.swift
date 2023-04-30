//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstAerodynamicConstraintsBatch: BurstConstraintsBatchImpl, IAerodynamicConstraintsBatchImpl
{
    private var aerodynamicCoeffs: [Float] = []

    public init(constraints: BurstAerodynamicConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Aerodynamics
    }

    public func SetAerodynamicConstraints(particleIndices _: [Int], aerodynamicCoeffs _: [Float], count _: Int) {}

    override public func Initialize(substepTime _: Float) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public struct AerodynamicConstraintsBatchJob {
        public private(set) var particleIndices: [Int]
        public private(set) var aerodynamicCoeffs: [Float]

        public private(set) var positions: [float4]
        public private(set) var normals: [float4]
        public private(set) var wind: [float4]
        public private(set) var invMasses: [Float]

        public private(set) var velocities: [float4]

        public private(set) var deltaTime: Float

        public func Execute(i _: Int) {}
    }
}
