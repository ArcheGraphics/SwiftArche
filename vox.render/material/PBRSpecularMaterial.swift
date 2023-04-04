//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

public class PBRSpecularMaterial: PBRBaseMaterial {
    /// Specular color.
    @Serialized(default: Color(1, 1, 1))
    public var specularColor: Color {
        didSet {
            shaderData.setData(with: PBRSpecularMaterial._specularProp, data: specularColor.toLinear())
        }
    }

    /// Glossiness.
    @Serialized(default: 1)
    public var glossiness: Float {
        didSet {
            shaderData.setData(with: PBRSpecularMaterial._glossinessProp, data: glossiness)
        }
    }

    /// Specular glossiness texture.
    public var specularGlossinessTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRSpecularMaterial._specularGlossinessTextureProp,
                                       PBRSpecularMaterial._specularGlossinessSamplerProp, texture: specularGlossinessTexture)
            if specularGlossinessTexture != nil {
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            }
        }
    }
    
    public var specularGlossinessSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRSpecularMaterial._specularGlossinessSamplerProp, sampler: specularGlossinessSampler)
        }
    }
    
    public required init() {
        super.init()
        shaderData.setData(with: PBRSpecularMaterial._specularProp, data: specularColor.toLinear())
        shaderData.setData(with: PBRSpecularMaterial._glossinessProp, data: glossiness)
    }
}
