//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class KHR_materials_clearcoat {
    static func parseEngineResource(_ schema: GLTFClearcoatParams, _ material: PBRBaseMaterial, _ context: ParserContext) {
        let glTFResource = context.glTFResource!
        material.clearCoat = schema.clearcoatFactor
        material.clearCoatRoughness = schema.clearcoatRoughnessFactor

        if let clearcoatTexture = schema.clearcoatTexture,
           let samplers = glTFResource.samplers
        {
            material.clearCoatTexture = glTFResource.textures![clearcoatTexture.index]
            if let sampler = samplers[clearcoatTexture.index] {
                material.clearCoatSampler = sampler
            }
            KHR_texture_transform.parseEngineResource(clearcoatTexture.transform, material, context)
        }
        if let clearcoatRoughnessTexture = schema.clearcoatRoughnessTexture,
           let samplers = glTFResource.samplers
        {
            material.clearCoatRoughnessTexture = glTFResource.textures![clearcoatRoughnessTexture.index]
            if let samplers = samplers[clearcoatRoughnessTexture.index] {
                material.clearCoatRoughnessSampler = samplers
            }
            KHR_texture_transform.parseEngineResource(clearcoatRoughnessTexture.transform, material, context)
        }
        if let clearcoatNormalTexture = schema.clearcoatNormalTexture,
           let samplers = glTFResource.samplers
        {
            material.clearCoatNormalTexture = glTFResource.textures![clearcoatNormalTexture.index]
            if let samplers = samplers[clearcoatNormalTexture.index] {
                material.clearCoatNormalSampler = samplers
            }
            KHR_texture_transform.parseEngineResource(clearcoatNormalTexture.transform, material, context)
        }
    }
}
