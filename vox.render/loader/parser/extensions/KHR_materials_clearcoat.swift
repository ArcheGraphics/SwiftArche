//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class KHR_materials_clearcoat {
    static func parseEngineResource(_ schema: GLTFClearcoatParams, _ material: PBRBaseMaterial, _ context: ParserContext) {
        material.clearCoat = schema.clearcoatFactor
        material.clearCoatRoughness = schema.clearcoatRoughnessFactor

        if schema.clearcoatTexture != nil {
            material.clearCoatTexture = context.glTFResource.textures![schema.clearcoatTexture!.index]
            KHR_texture_transform.parseEngineResource(schema.clearcoatTexture!.transform, material, context)
        }
        if schema.clearcoatRoughnessTexture != nil {
            material.clearCoatRoughnessTexture = context.glTFResource.textures![schema.clearcoatRoughnessTexture!.index]
            KHR_texture_transform.parseEngineResource(schema.clearcoatRoughnessTexture!.transform, material, context)
        }
        if schema.clearcoatNormalTexture != nil {
            material.clearCoatNormalTexture = context.glTFResource.textures![schema.clearcoatNormalTexture!.index]
            KHR_texture_transform.parseEngineResource(schema.clearcoatNormalTexture!.transform, material, context)
        }
    }
}