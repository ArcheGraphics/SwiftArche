//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// PBR (Metallic-Roughness Workflow) Material.
public class PBRMaterial: PBRBaseMaterial {
    /// Metallic, default 1.0.
    @Serialized(default: 1)
    public var metallic: Float {
        didSet {
            shaderData.setData(with: PBRMaterial._metallicProp, data: metallic)
        }
    }

    /// Roughness, default 1.0
    @Serialized(default: 1)
    public var roughness: Float {
        didSet {
            shaderData.setData(with: PBRMaterial._roughnessProp, data: roughness)
        }
    }

    /// Roughness metallic texture.
    public var roughnessMetallicTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRMaterial._roughnessMetallicTextureProp,
                                       PBRMaterial._roughnessMetallicSamplerProp, texture: roughnessMetallicTexture)
            if roughnessMetallicTexture != nil {
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            }
        }
    }
    
    public var roughnessMetallicSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRMaterial._roughnessMetallicSamplerProp, sampler: roughnessMetallicSampler)
        }
    }
    
    public required init() {
        super.init()
        shaderData.enableMacro(IS_METALLIC_WORKFLOW.rawValue)
        
        shaderData.setData(with: PBRMaterial._metallicProp, data: metallic)
        shaderData.setData(with: PBRMaterial._roughnessProp, data: roughness)
    }
}
