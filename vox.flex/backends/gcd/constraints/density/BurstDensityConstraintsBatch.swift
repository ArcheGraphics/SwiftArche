//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstDensityConstraintsBatch: BurstConstraintsBatchImpl {
    public var batchData: BatchData!

    public init(constraints: BurstDensityConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Density
    }

    override public func Initialize(substepTime _: Float) {}

    override public func Evaluate(stepTime _: Float, substepTime _: Float, substeps _: Int) {}

    override public func Apply(substepTime _: Float) {}

    public func CalculateViscosityAndNormals(deltaTime _: Float) {}
    public func CalculateVorticity() {}
    public func AccumulateSmoothPositions() {}
    public func AccumulateAnisotropy() {}

    public struct UpdateDensitiesJob {
        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]
        public private(set) var restDensities: [Float]
        public private(set) var diffusion: [Float]
        public private(set) var pairs: [FluidInteraction]

        public var userData: [float4]
        public var fluidData: [float4]

        public private(set) var batchData: BatchData

        public private(set) var dt: Float

        public func Execute(workItemIndex _: Int) {}
    }

    public struct ApplyDensityConstraintsJob {
        public private(set) var invMasses: [Float]
        public private(set) var radii: [Float]
        public private(set) var restDensities: [Float]
        public private(set) var surfaceTension: [Float]
        public private(set) var pairs: [FluidInteraction]
        public private(set) var densityKernel: Poly6Kernel

        public var positions: [float4]
        public var fluidData: [float4]

        public private(set) var batchData: BatchData
        public private(set) var sorFactor: Float

        public func Execute(workItemIndex _: Int) {}
    }

    public struct NormalsViscosityAndVorticityJob {
        public private(set) var positions: [float4]
        public private(set) var invMasses: [Float]
        public private(set) var radii: [Float]
        public private(set) var restDensities: [Float]
        public private(set) var viscosities: [Float]
        public private(set) var fluidData: [float4]
        public private(set) var pairs: [FluidInteraction]

        public var velocities: [float4]
        public var vorticities: [float4]
        public var normals: [float4]

        public private(set) var batchData: BatchData

        public func Execute(workItemIndex _: Int) {}
    }

    public struct CalculateVorticityEta {
        public private(set) var vorticities: [float4]
        public private(set) var invMasses: [Float]
        public private(set) var restDensities: [Float]

        public var pairs: [FluidInteraction]
        public var eta: [float4]

        public private(set) var batchData: BatchData

        public func Execute(workItemIndex _: Int) {}
    }

    public struct AccumulateSmoothPositionsJob {
        public private(set) var renderablePositions: [float4]
        public private(set) var radii: [Float]
        public private(set) var densityKernel: Poly6Kernel

        public var smoothPositions: [float4]
        public var pairs: [FluidInteraction]

        public private(set) var batchData: BatchData

        public func Execute(workItemIndex _: Int) {}
    }

    public struct AccumulateAnisotropyJob {
        public private(set) var renderablePositions: [float4]
        public private(set) var smoothPositions: [float4]
        public private(set) var pairs: [FluidInteraction]

        public var anisotropies: [float3x3]

        public private(set) var batchData: BatchData

        public func Execute(workItemIndex _: Int) {}
    }
}
