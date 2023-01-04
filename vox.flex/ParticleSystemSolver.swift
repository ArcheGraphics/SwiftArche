//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public final class ParticleSystemSolver: ParticleSystemSolverBase {
    private var _radius: Float = 1e-3
    private var _mass: Float = 1e-3
    private var _timeIntegration: ComputePass
    private var _accumulateExternalForces: ComputePass
    
    public var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
        }
    }
    
    public var mass: Float {
        get {
            _mass
        }
        set {
            _mass = newValue
        }
    }
    
    public required init(_ entity: Entity) {
        _timeIntegration = ComputePass(entity.engine)
        _accumulateExternalForces = ComputePass(entity.engine)
        super.init(entity)
        
        _timeIntegration.shader.append(ShaderPass(engine.library("vox.flex"), "semiImplicitEuler"))
        _timeIntegration.resourceCache = resourceCache
        _accumulateExternalForces.shader.append(ShaderPass(engine.library("vox.flex"), "gravityForce"))
        _accumulateExternalForces.resourceCache = resourceCache
    }
    
    public override func initialize(_ commandBuffer: MTLCommandBuffer) {
        // When initializing the solver, update the collider and emitter state as
        // well since they also affects the initial condition of the simulation.
        updateCollider(commandBuffer, 0.0)
        updateEmitter(commandBuffer, 0.0)
    }
    
    public override func onAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        beginAdvanceTimeStep(commandBuffer, timeStepInSeconds)
        
        accumulateForces(commandBuffer, timeStepInSeconds)
        timeIntegration(commandBuffer, timeStepInSeconds)
        resolveCollision(commandBuffer)
        
        endAdvanceTimeStep(commandBuffer, timeStepInSeconds)
    }
    
    /// Accumulates forces applied to the particles.
    public func accumulateForces(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        // Add external forces
        accumulateExternalForces(commandBuffer)
    }

    /// Called when a time-step is about to begin.
    public func onBeginAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
    }

    /// Called after a time-step is completed.
    public func onEndAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
    }
    
    public func beginAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        // Update collider and emitter
        updateCollider(commandBuffer, timeStepInSeconds)
        updateEmitter(commandBuffer, timeStepInSeconds)

        onBeginAdvanceTimeStep(commandBuffer, timeStepInSeconds)
    }

    public func endAdvanceTimeStep(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        onEndAdvanceTimeStep(commandBuffer, timeStepInSeconds)
    }

    public func accumulateExternalForces(_ commandBuffer: MTLCommandBuffer) {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _accumulateExternalForces.compute(commandEncoder: commandEncoder, label: "accumulate external forces")
            commandEncoder.endEncoding()
        }
    }

    public func timeIntegration(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            _timeIntegration.compute(commandEncoder: commandEncoder, label: "time integration")
            commandEncoder.endEncoding()
        }
    }
    
    /// Resolves any collisions occured by the particles.
    public func resolveCollision(_ commandBuffer: MTLCommandBuffer) {}

    public func updateCollider(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}

    public func updateEmitter(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let emitter = _emitter,
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            emitter.update(commandEncoder, currentTimeInSeconds: currentTime, timeIntervalInSeconds: timeStepInSeconds)
            commandEncoder.endEncoding()
        }
    }
}
