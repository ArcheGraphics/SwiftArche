//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class KHR_materials_pbrSpecularGlossiness {
    static func createEngineResource(schema: GLTFPBRSpecularGlossinessParams, context: ParserContext) -> PBRSpecularMaterial {
        let material = PBRSpecularMaterial(context.engine)

        material.baseColor = Color(
                Color.linearToGammaSpace(value: schema.diffuseFactor.x),
                Color.linearToGammaSpace(value: schema.diffuseFactor.y),
                Color.linearToGammaSpace(value: schema.diffuseFactor.z),
                schema.diffuseFactor.w
        )

        if (schema.diffuseTexture != nil) {
            material.baseTexture = context.glTFResource.textures![schema.diffuseTexture!.index]
        }

        material.specularColor = Vector3(
                Color.linearToGammaSpace(value: schema.specularFactor.x),
                Color.linearToGammaSpace(value: schema.specularFactor.y),
                Color.linearToGammaSpace(value: schema.specularFactor.z)
        )
        material.glossiness = schema.glossinessFactor

        if (schema.specularGlossinessTexture != nil) {
            material.specularGlossinessTexture = context.glTFResource.textures![schema.specularGlossinessTexture!.index]
        }

        return material
    }
}