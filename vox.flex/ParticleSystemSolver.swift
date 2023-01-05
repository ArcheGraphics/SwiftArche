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
    private let _indirectArgsBuffer: BufferView
    private let _initArgsPass: ComputePass
    private let _timeIntegration: ComputePass
    private let _accumulateExternalForces: ComputePass
    
    public var radius: Float {
        get {
            _radius
        }
        set {
            _radius = newValue
            _particleSystemData?.radius = newValue
        }
    }
    
    public var mass: Float {
        get {
            _mass
        }
        set {
            _mass = newValue
            _particleSystemData?.mass = newValue
        }
    }
    
    public override var emitter: ParticleEmitter? {
        get {
            _emitter
        }
        set {
            _emitter = newValue
            if _particleSystemData == nil {
                _particleSystemData = ParticleSystemData(engine, maxLength: ParticleSystemSolverBase.maxLength)
                _particleSystemData?.mass = _mass
                _particleSystemData?.radius = _radius
            }
            _emitter?.target = _particleSystemData
            _emitter?.resourceCache = resourceCache
        }
    }
    
    public required init(_ entity: Entity) {
        let engine = entity.engine
        _timeIntegration = ComputePass(engine)
        _accumulateExternalForces = ComputePass(engine)
        _indirectArgsBuffer = BufferView(device: engine.device, count: 1,
                                         stride: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride)
        _initArgsPass = ComputePass(engine)
        super.init(entity)
    }
    
    public override func initialize(_ commandBuffer: MTLCommandBuffer) {
        if let particleSystemData = particleSystemData {
            _initArgsPass.resourceCache = resourceCache
            _initArgsPass.shader.append(ShaderPass(engine.library("flex.shader"), "initSortArgs"))
            _initArgsPass.defaultShaderData.setData("args", _indirectArgsBuffer)
            _initArgsPass.defaultShaderData.setData("g_NumElements", particleSystemData.numberOfParticles)
            _initArgsPass.precompileAll()
            
            _timeIntegration.shader.append(ShaderPass(engine.library("flex.shader"), "semiImplicitEuler"))
            _timeIntegration.resourceCache = resourceCache
            _timeIntegration.data.append(particleSystemData)
            
            _accumulateExternalForces.shader.append(ShaderPass(engine.library("flex.shader"), "gravityForce"))
            _accumulateExternalForces.resourceCache = resourceCache
            _accumulateExternalForces.data.append(particleSystemData)
        }
        
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
            commandEncoder.label = "accumulate external forces"
            _accumulateExternalForces.defaultShaderData.setData("u_forceData", ForceData(gravity: gravity, mass: mass))
            _accumulateExternalForces.compute(commandEncoder: commandEncoder, indirectBuffer: _indirectArgsBuffer.buffer,
                                              threadsPerThreadgroup: MTLSize(width: 512, height: 1, depth: 1), label: "gravity forces")
            commandEncoder.endEncoding()
        }
    }
    
    public func timeIntegration(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        var timeStepInSeconds = timeStepInSeconds
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.label = "time integration"
            commandEncoder.setBytes(&timeStepInSeconds, length: MemoryLayout<Float>.stride, index: 3)
            commandEncoder.setBytes(&mass, length: MemoryLayout<Float>.stride, index: 4)
            _timeIntegration.compute(commandEncoder: commandEncoder, indirectBuffer: _indirectArgsBuffer.buffer,
                                     threadsPerThreadgroup: MTLSize(width: 512, height: 1, depth: 1), label: "euler integration")
            commandEncoder.endEncoding()
        }
    }
    
    /// Resolves any collisions occured by the particles.
    public func resolveCollision(_ commandBuffer: MTLCommandBuffer) {
        if let collider = collider,
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.label = "collision"
            collider.update(commandEncoder: commandEncoder, indirectBuffer: _indirectArgsBuffer.buffer,
                            threadsPerThreadgroup: MTLSize(width: 512, height: 1, depth: 1))
            commandEncoder.endEncoding()
        }
    }
    
    public func updateCollider(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {}
    
    public func updateEmitter(_ commandBuffer: MTLCommandBuffer, _ timeStepInSeconds: Float) {
        if let emitter = _emitter,
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.label = "emitter"
            emitter.update(commandEncoder, currentTimeInSeconds: currentTime, timeIntervalInSeconds: timeStepInSeconds)
            _initArgsPass.compute(commandEncoder: commandEncoder, label: "initArgs")
            commandEncoder.endEncoding()
        }
    }
}
