//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

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

        if (schema.diffuseTexture != nil) {
            material.baseTexture = glTFResource.textures![schema.diffuseTexture!.index]
            material.setBaseSampler(value: glTFResource.samplers![schema.diffuseTexture!.index])
            KHR_texture_transform.parseEngineResource(schema.diffuseTexture!.transform, material, context)
        }

        material.specularColor = Color(
                Color.linearToGammaSpace(value: schema.specularFactor.x),
                Color.linearToGammaSpace(value: schema.specularFactor.y),
                Color.linearToGammaSpace(value: schema.specularFactor.z),
                1.0
        )
        material.glossiness = schema.glossinessFactor

        if (schema.specularGlossinessTexture != nil) {
            material.specularGlossinessTexture = glTFResource.textures![schema.specularGlossinessTexture!.index]
            material.setSpecularGlossinessSampler(value: glTFResource.samplers![schema.specularGlossinessTexture!.index])
            KHR_texture_transform.parseEngineResource(schema.specularGlossinessTexture!.transform, material, context)
        }

        return material
    }
}
