//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

open class SphSolverBase: ParticleSystemSolver {
    static let kTimeStepLimitBySpeedFactor: Float = 0.4
    static let kTimeStepLimitByForceFactor: Float = 0.25
    
    private var _negativePressureScale: Float = 0.0
    private var _viscosityCoefficient: Float = 0.01
    private var _pseudoViscosityCoefficient: Float = 10.0
    private var _speedOfSound: Float = 100.0
    private var _timeStepLimitScale: Float = 1.0
    
    /// the particle system data.
    public var sphSystemData: SphSystemData? {
        get {
            _particleSystemData as? SphSystemData
        }
    }
    
    /// the emitter.
    public override var emitter: ParticleEmitter? {
        get {
            _emitter
        }
        set {
            _emitter = newValue
            if _particleSystemData == nil {
                _particleSystemData = SphSystemData(engine, maxLength: ParticleSystemSolverBase.maxLength)
            }
            _emitter?.target = _particleSystemData
        }
    }
    
    public var negativePressureScale: Float {
        get {
            _negativePressureScale
        }
        set {
            _negativePressureScale = newValue
        }
    }
    
    public var viscosityCoefficient: Float {
        get {
            _viscosityCoefficient
        }
        set {
            _viscosityCoefficient = newValue
        }
    }
    
    public var pseudoViscosityCoefficient: Float {
        get {
            _pseudoViscosityCoefficient
        }
        set {
            _pseudoViscosityCoefficient = newValue
        }
    }
    
    public var speedOfSound: Float {
        get {
            _speedOfSound
        }
        set {
            _speedOfSound = max(newValue, Float.leastNonzeroMagnitude)
        }
    }
    
    public var timeStepLimitScale: Float {
        get {
            _timeStepLimitScale
        }
        set {
            _timeStepLimitScale = max(newValue, 0)
        }
    }
    
    public required init(_ engine: Engine) {
        super.init(engine)
        isUsingFixedSubTimeSteps = false
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        isUsingFixedSubTimeSteps = false
    }
    
    open override func numberOfSubTimeSteps(_ timeIntervalInSeconds: Float) -> UInt {
        if let sphSystemData = sphSystemData {
            let kernelRadius = sphSystemData.kernelRadius
            let mass = sphSystemData.mass
            
            var maxForceMagnitude: Float = 0.0
            maxForceMagnitude = kGravity
            
            let timeStepLimitBySpeed = SphSolverBase.kTimeStepLimitBySpeedFactor * kernelRadius / _speedOfSound
            let timeStepLimitByForce = SphSolverBase.kTimeStepLimitByForceFactor * sqrt(kernelRadius * mass / maxForceMagnitude)
            let desiredTimeStep = timeStepLimitScale * min(timeStepLimitBySpeed, timeStepLimitByForce)
            
            return UInt(ceil(timeIntervalInSeconds / desiredTimeStep))
        } else {
            return super.numberOfSubTimeSteps(timeIntervalInSeconds)
        }
    }
}
