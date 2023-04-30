//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstDensityConstraints: BurstConstraintsImpl<BurstDensityConstraintsBatch> {
    public var fluidParticles: [Int] = []

    public var eta: [float4] = []
    public var smoothPositions: [float4] = []
    public var anisotropies: [float3x3] = []

    public init(solver: BurstSolverImpl) {
        super.init(solver: solver, constraintType: Oni.ConstraintType.Density)
    }

    override public func CreateConstraintsBatch() -> IConstraintsBatchImpl {
        let dataBatch = BurstDensityConstraintsBatch(constraints: self)
        batches.append(dataBatch)
        return dataBatch
    }

    override public func RemoveBatch(batch: IConstraintsBatchImpl) {
        batches.removeAll { b in
            b === (batch as! BurstDensityConstraintsBatch)
        }
        batch.Destroy()
    }

    func EvaluateSequential(stepTime _: Float, substepTime _: Float, substeps _: Int) {}
    func EvaluateParallel(stepTime _: Float, substepTime _: Float, substeps _: Int) {}
    public func ApplyVelocityCorrections(deltaTime _: Float) {}
    public func CalculateAnisotropyLaplacianSmoothing() {}
    private func UpdateInteractions() {}
    private func CalculateLambdas(deltaTime _: Float) {}
    private func ApplyVorticityAndAtmosphere(deltaTime _: Float) {}
    private func IdentityAnisotropy() {}
    private func AverageSmoothPositions() {}
    private func AverageAnisotropy() {}

    public struct ClearFluidDataJob {
        public private(set) var fluidParticles: [Int]
        public var fluidData: [float4]

        public mutating func Execute(i: Int) {
            fluidData[fluidParticles[i]] = float4.zero
        }
    }

    public struct UpdateInteractionsJob {
        public private(set) var positions: [float4]
        public private(set) var radii: [Float]
        public private(set) var densityKernel: Poly6Kernel
        public private(set) var gradientKernel: SpikyKernel

        public var pairs: [FluidInteraction]

        public var batchData: BatchData

        public func Execute(i _: Int) {}
    }

    public struct CalculateLambdasJob {
        public private(set) var fluidParticles: [Int]
        public private(set) var invMasses: [Float]
        public private(set) var radii: [Float]
        public private(set) var restDensities: [Float]
        public private(set) var surfaceTension: [Float]
        public private(set) var densityKernel: Poly6Kernel
        public private(set) var gradientKernel: SpikyKernel

        public var normals: [float4]
        public var vorticity: [float4]
        public var fluidData: [float4]

        public func Execute(p _: Int) {}
    }

    public struct ApplyVorticityConfinementAndAtmosphere {
        public private(set) var fluidParticles: [Int]
        public private(set) var wind: [float4]
        public private(set) var vorticities: [float4]
        public private(set) var atmosphericDrag: [Float]
        public private(set) var atmosphericPressure: [Float]
        public private(set) var vorticityConfinement: [Float]
        public private(set) var restDensities: [Float]
        public private(set) var normals: [float4]
        public private(set) var fluidData: [float4]

        public private(set) var eta: [float4]

        public var velocities: [float4]

        public private(set) var dt: Float

        public func Execute(p _: Int) {}
    }

    public struct IdentityAnisotropyJob {
        public private(set) var fluidParticles: [Int]
        public private(set) var radii: [float4]

        public var principalAxes: [float4]

        public func Execute(p _: Int) {}
    }

    public struct AverageSmoothPositionsJob {
        public private(set) var fluidParticles: [Int]
        public private(set) var renderablePositions: [float4]

        public var smoothPositions: [float4]

        public func Execute(p _: Int) {}
    }

    public struct AverageAnisotropyJob {
        public private(set) var fluidParticles: [Int]
        public private(set) var principalRadii: [float4]
        public private(set) var maxAnisotropy: Float

        public private(set) var smoothPositions: [float4]

        public private(set) var anisotropies: [float3x3]

        public var renderablePositions: [float4]
        public var principalAxes: [float4]

        public func Execute(p _: Int) {}
    }
}
