//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class KHR_materials_clearcoat {
    static func parseEngineResource(schema: GLTFClearcoatParams, material: PBRMaterial, context: GLTFResource) {
        material.clearCoat = schema.clearcoatFactor
        material.clearCoatRoughness = schema.clearcoatRoughnessFactor

        if schema.clearcoatTexture != nil {
            material.clearCoatTexture = context.textures![schema.clearcoatTexture!.index]
        }
        if schema.clearcoatRoughnessTexture != nil {
            material.clearCoatRoughnessTexture = context.textures![schema.clearcoatRoughnessTexture!.index]
        }
        if schema.clearcoatNormalTexture != nil {
            material.clearCoatNormalTexture = context.textures![schema.clearcoatNormalTexture!.index]
        }
    }
}