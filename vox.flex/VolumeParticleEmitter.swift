//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

public class VolumeParticleEmitter: ParticleEmitter {
    private static let emitterProperty = "u_emitterData"
    
    private var _jitter: Float = 0
    private var _maxRegion = BoundingBox3F()
    private var _spacing: Float = 0
    private var _initialVelocity = Vector3F()
    private var _linearVelocity = Vector3F()
    private var _angularVelocity = Vector3F()
    private var _maxNumberOfParticles: UInt32 = 0
    private var _isOneShot: Bool = false
    private var _allowOverlapping: Bool = false
    private var _implicitSurface: ImplicitTriangleMesh?
    private var _data = VolumeParticleEmitterData()

    public var implicitSurface: ImplicitTriangleMesh? {
        get {
            _implicitSurface
        }
        set {
            _implicitSurface = newValue
            if let sdf = newValue?.sdf {
                defaultShaderData.setImageView("u_sdfTexture", "u_sdfSampler", sdf)
                defaultShaderData.enableMacro(HAS_SDF.rawValue)
            } else {
                defaultShaderData.setImageView("u_sdfTexture", "u_sdfSampler", nil)
                defaultShaderData.disableMacro(HAS_SDF.rawValue)
            }
        }
    }
    
    public var jitter: Float {
        get {
            _jitter
        }
        set {
            _jitter = simd_clamp(newValue, 0.0, 1.0)
            _data.jitter = _jitter
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var maxRegion: BoundingBox3F {
        get {
            _maxRegion
        }
        set {
            _maxRegion = newValue
            _data.lowerCorner = newValue.lowerCorner
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var spacing: Float {
        get {
            _spacing
        }
        set {
            _spacing = newValue
            _data.spacing = newValue
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var initialVelocity: Vector3F {
        get {
            _initialVelocity
        }
        set {
            _initialVelocity = newValue
            _data.initialVelocity = newValue
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var linearVelocity: Vector3F {
        get {
            _linearVelocity
        }
        set {
            _linearVelocity = newValue
            _data.linearVelocity = newValue
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var angularVelocity: Vector3F {
        get {
            _angularVelocity
        }
        set {
            _angularVelocity = newValue
            _data.angularVelocity = newValue
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var maxNumberOfParticles: UInt32 {
        get {
            _maxNumberOfParticles
        }
        set {
            _maxNumberOfParticles = newValue
            _data.maxNumberOfParticles = newValue
            defaultShaderData.setData(VolumeParticleEmitter.emitterProperty, _data)
        }
    }
    
    public var isOneShot: Bool {
        get {
            _isOneShot
        }
        set {
            _isOneShot = newValue
        }
    }
    
    public var allowOverlapping: Bool {
        get {
            _allowOverlapping
        }
        set {
            _allowOverlapping = newValue
        }
    }
    
    public override init(_ engine: Engine) {
        super.init(engine)
        shader.append(ShaderPass(engine.library("flex.shader"), "volumeEmitter"))
    }

    public override func update(_ commandEncoder: MTLComputeCommandEncoder,
                                currentTimeInSeconds: Float, timeIntervalInSeconds: Float) {
        if let target = target {
            if (!isEnabled) {
                return
            }
            emit(commandEncoder, target)
            
            if _isOneShot {
                isEnabled = false
            }
        }
    }
    
    private func emit(_ commandEncoder: MTLComputeCommandEncoder,
                      _ target: ParticleSystemData) {
        let region = _maxRegion
        let boxWidth = region.width
        let boxHeight = region.height
        let boxDepth = region.depth
        threadsPerGridX = Int(boxWidth / _spacing)
        threadsPerGridY = Int(boxHeight / _spacing)
        threadsPerGridZ = Int(boxDepth / _spacing)
        compute(commandEncoder: commandEncoder)
    }
}
