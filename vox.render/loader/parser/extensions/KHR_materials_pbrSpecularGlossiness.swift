//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class KHR_materials_pbrSpecularGlossiness {
    static func createEngineResource(_ schema: GLTFPBRSpecularGlossinessParams, _ context: ParserContext) -> PBRSpecularMaterial {
        let glTFResource = context.glTFResource!
        let material = PBRSpecularMaterial(glTFResource.engine)

        material.baseColor = Color(
                Color.linearToGammaSpace(value: schema.diffuseFactor.x),
                Color.linearToGammaSpace(value: schema.diffuseFactor.y),
                Color.linearToGammaSpace(value: schema.diffuseFactor.z),
                schema.diffuseFactor.w
        )

        if let diffuseTexture = schema.diffuseTexture,
           let samplers = glTFResource.samplers {
            material.baseTexture = glTFResource.textures![diffuseTexture.index]
            if let sampler = samplers[diffuseTexture.index] {
                material.setBaseSampler(value: sampler)
            }
            KHR_texture_transform.parseEngineResource(diffuseTexture.transform, material, context)
        }

        material.specularColor = Color(
                Color.linearToGammaSpace(value: schema.specularFactor.x),
                Color.linearToGammaSpace(value: schema.specularFactor.y),
                Color.linearToGammaSpace(value: schema.specularFactor.z),
                1.0
        )
        material.glossiness = schema.glossinessFactor

        if let specularGlossinessTexture = schema.specularGlossinessTexture,
           let samplers = glTFResource.samplers {
            material.specularGlossinessTexture = glTFResource.textures![specularGlossinessTexture.index]
            if let sampler = samplers[specularGlossinessTexture.index] {
                material.setSpecularGlossinessSampler(value: sampler)
            }
            KHR_texture_transform.parseEngineResource(specularGlossinessTexture.transform, material, context)
        }

        return material
    }
}
