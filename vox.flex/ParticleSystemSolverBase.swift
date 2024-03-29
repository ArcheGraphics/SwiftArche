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
open class ParticleSystemSolverBase: PhysicsAnimation {
    public static var maxLength: UInt32 = 10000

    var _collider: ParticleCollider?
    var _emitter: ParticleEmitter?
    var _particleSystemData: ParticleSystemData?

    private var _dragCoefficient: Float = 1e-4
    private var _gravity = Vector3F(0, -9.8, 0)

    /// the gravity.
    public var gravity: Vector3F {
        get {
            _gravity
        }
        set {
            _gravity = newValue
        }
    }

    /// The drag coefficient.
    public var dragCoefficient: Float {
        get {
            _dragCoefficient
        }
        set {
            _dragCoefficient = max(newValue, 0)
        }
    }

    /// the particle system data.
    public var particleSystemData: ParticleSystemData? {
        _particleSystemData
    }

    /// the emitter.
    public var emitter: ParticleEmitter? {
        get {
            _emitter
        }
        set {
            _emitter = newValue
            if _particleSystemData == nil {
                _particleSystemData = ParticleSystemData(maxLength: ParticleSystemSolverBase.maxLength)
            }
            _emitter?.target = _particleSystemData
        }
    }

    /// the collider.
    public var collider: ParticleCollider? {
        get {
            _collider
        }
        set {
            _collider = newValue
            if _particleSystemData == nil {
                _particleSystemData = ParticleSystemData(maxLength: ParticleSystemSolverBase.maxLength)
            }
            _collider?.target = _particleSystemData
        }
    }

    public required init() {
        super.init()
    }
}
