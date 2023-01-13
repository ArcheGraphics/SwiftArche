//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

///
/// - 3-D SPH solver.
///
/// This class implements 3-D SPH solver. The main pressure solver is based on
/// equation-of-state (EOS).
///
/// - see M{\"u}ller et al., Particle-based fluid simulation for interactive
///      applications, SCA 2003.
///
/// - see M. Becker and M. Teschner, Weakly compressible SPH for free surface
///      flows, SCA 2007.
///
/// - see Adams and Wicke, Meshless approximation methods and applications in
///      physics based modeling and animation, Eurographics tutorials 2009.
///
public final class WCSphSolver: SphSolverBase {
    // WCSPH solver properties
    private var _eosExponent: Float = 7.0
    
    public var eosExponent: Float {
        get {
            _eosExponent
        }
        set {
            _eosExponent = max(newValue, 1.0)
        }
    }
    
    public required init(_ entity: Entity) {
        super.init(entity)
        let sph = SphSystemData(engine, maxLength: ParticleSystemSolverBase.maxLength)
        sph.targetDensity = kWaterDensity
        sph.targetSpacing = 0.1
        sph.relativeKernelRadius = 1.8
        _particleSystemData = sph
    }
    
    public override func onBeginAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let particleSystemData = particleSystemData as? SphSystemData {
            particleSystemData.buildNeighborSearcher(commandBuffer: commandBuffer, maxSearchRadius: particleSystemData.kernelRadius)
        }
    }
    
    public override func accumulateForces(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        accumulateNonPressureForces(commandBuffer, timeStepInSeconds)
        accumulatePressureForce(commandBuffer, timeStepInSeconds)
    }
    
    /// Accumulates the non-pressure forces to the forces array in the particle system.
    func accumulateNonPressureForces(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        super.accumulateForces(commandBuffer, timeStepInSeconds)
        accumulateViscosityForce(commandBuffer)
    }

    /// Accumulates the pressure force to the forces array in the particle system.
    func accumulatePressureForce(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.label = "accumulate pressure force"
            computePressure(commandEncoder)
            accumulatePressureForce(commandEncoder)
            commandEncoder.endEncoding()
        }
    }
    
    /// Computes the pressure.
    func computePressure(_ encoder: MTLCommandEncoder) {}

    /// Accumulates the pressure force to the given \p pressureForces array.
    func accumulatePressureForce(_ encoder: MTLCommandEncoder) {}
    
    /// Accumulates the viscosity force to the forces array in the particle system.
    func accumulateViscosityForce(_ commandBuffer: MTLCommandBuffer) {}
    
    public override func onEndAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.label = "post-process"
            computePseudoViscosity(commandEncoder, timeStepInSeconds)
            commandEncoder.endEncoding()
        }
    }
    
    /// Computes pseudo viscosity.
    func computePseudoViscosity(_ encoder: MTLCommandEncoder, _ timeStepInSeconds: Float) {}
}
