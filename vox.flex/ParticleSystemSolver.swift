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
        super.init(entity)
    }
    
    override func initialize(_ commandBuffer: MTLCommandBuffer) {
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

    public func accumulateExternalForces(_ commandBuffer: MTLCommandBuffer) {}

    public func timeIntegration(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}
    
    /// Resolves any collisions occured by the particles.
    public func resolveCollision(_ commandBuffer: MTLCommandBuffer) {}

    public func updateCollider(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}

    public func updateEmitter(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}
}
