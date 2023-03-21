//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

open class ParticleCollider : ComputePass {
    static let colliderProperty = "u_collider"
    var _target: ParticleSystemData?
    var _colliderData: ColliderData
    
    public var frictionCoefficient: Float {
        get {
            _colliderData.frictionCoefficient
        }
        set {
            _colliderData.frictionCoefficient = max(newValue, 0)
            defaultShaderData.setData(ParticleCollider.colliderProperty, _colliderData)
        }
    }
    
    /// The restitution coefficient.
    public var restitutionCoefficient: Float {
        get {
            _colliderData.restitutionCoefficient
        }
        set {
            _colliderData.restitutionCoefficient = simd_clamp(newValue, 0, 1)
            defaultShaderData.setData(ParticleCollider.colliderProperty, _colliderData)
        }
    }
    
    public var target: ParticleSystemData? {
        get {
            _target
        }
        set {
            _target = newValue
            if let target = _target {
                _colliderData.radius = target.radius
                defaultShaderData.setData(ParticleCollider.colliderProperty, _colliderData)
                data.append(target)
            }
        }
    }
    
    public override init() {
        _colliderData = ColliderData(radius: 1e-3, restitutionCoefficient: 0, frictionCoefficient: 0, count: 0)
        super.init()
        
        defaultShaderData.setData(ParticleCollider.colliderProperty, _colliderData)
    }
    
    open func update(commandEncoder: MTLComputeCommandEncoder, indirectBuffer: MTLBuffer, threadsPerThreadgroup: MTLSize) {}
}
