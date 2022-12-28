//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

///
/// Basic 3-D particle system solver.
///
/// This class implements basic particle system solver. It includes gravity,
/// air drag, and collision. But it does not compute particle-to-particle
/// interaction. Thus, this solver is suitable for performing simple spray-like
/// simulations with low computational cost. This class can be further extend
/// to add more sophisticated simulations, such as SPH, to handle
/// particle-to-particle intersection.
///
open class ParticleSystemSolver: PhysicsAnimation {
    private var _emitter: ParticleEmitter?
    private var _particleSystemData: ParticleSystemData
    private var _dragCoefficient: Float = 1e-4
    private var _restitutionCoefficient: Float = 0
    
    /// the gravity.
    public var gravity = Vector3F(0, -9.8, 0)
    
    /// The drag coefficient.
    public var dragCoefficient: Float {
        get {
            _dragCoefficient
        }
        set {
            _dragCoefficient = max(newValue, 0)
        }
    }
    
    /// The restitution coefficient.
    public var restitutionCoefficient: Float {
        get {
            _restitutionCoefficient
        }
        set {
            _restitutionCoefficient = simd_clamp(newValue, 0, 1)
        }
    }
    
    /// the particle system data.
    public var particleSystemData: ParticleSystemData {
        get {
            _particleSystemData
        }
    }
    
    /// the emitter.
    public var emitter: ParticleEmitter? {
        get {
            _emitter
        }
        set {
            _emitter = newValue
            _emitter?.target = _particleSystemData
        }
    }
    
    public init(_ entity: Entity, maxLength: UInt32) {
        _particleSystemData = ParticleSystemData(entity.engine, maxLength: maxLength)
        super.init(entity)
    }
    
    required public init(_ entity: Entity) {
        fatalError("init(_:) has not been implemented")
    }
    
    open override func onAdvanceTimeStep(_ timeIntervalInSeconds: Float) {
        
    }
}
