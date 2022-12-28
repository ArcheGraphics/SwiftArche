//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

///
/// 3-D point particle emitter.
///
/// This class emits particles from a single point in given direction, speed,
/// and spreading angle.
///
public class PointParticleEmitter: ParticleEmitter {
    private static let emitterProperty = "u_emitterData"
    
    private var _data = PointParticleEmitterData()
    private var _firstFrameTimeInSeconds: Float = 0.0
    private var _numberOfEmittedParticles: Int = 0
    
    /// max number of new particles per second.
    public var maxNumberOfNewParticlesPerSecond: Int = 1
    
    public var origin: Vector3F {
        get {
            _data.origin
        }
        set {
            _data.origin = newValue
            defaultShaderData.setData(PointParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var direction: Vector3F {
        get {
            _data.direction
        }
        set {
            _data.direction = newValue
            defaultShaderData.setData(PointParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var speed: Float {
        get {
            _data.speed
        }
        set {
            _data.speed = newValue
            defaultShaderData.setData(PointParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var spreadAngleInRadians: Float {
        get {
            _data.spreadAngleInRadians
        }
        set {
            _data.spreadAngleInRadians = newValue
            defaultShaderData.setData(PointParticleEmitter.emitterProperty, _data)
        }
    }
    
    public override func update(_ commandEncoder: MTLComputeCommandEncoder, currentTimeInSeconds: Float, timeIntervalInSeconds: Float) {
        if let target = target {
            if (_numberOfEmittedParticles == 0) {
                _firstFrameTimeInSeconds = currentTimeInSeconds;
            }
            
            let elapsedTimeInSeconds = currentTimeInSeconds - _firstFrameTimeInSeconds;
            
            var newMaxTotalNumberOfEmittedParticles = Int(ceil((elapsedTimeInSeconds + timeIntervalInSeconds) * Float(maxNumberOfNewParticlesPerSecond)))
            newMaxTotalNumberOfEmittedParticles = min(newMaxTotalNumberOfEmittedParticles, Int(target.maxNumberOfParticles));
            let maxNumberOfNewParticles = newMaxTotalNumberOfEmittedParticles - _numberOfEmittedParticles;
            
            if (maxNumberOfNewParticles > 0) {
                threadsPerGridX = maxNumberOfNewParticles
                _numberOfEmittedParticles += maxNumberOfNewParticles
                compute(commandEncoder: commandEncoder)
            }
        }
    }
}
