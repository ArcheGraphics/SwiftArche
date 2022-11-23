//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class KHR_texture_transform {
    static func parseEngineResource(_ schema: GLTFTextureTransform?,
                                    _ material: UnlitMaterial,
                                    _ context: ParserContext) {
        if let schema = schema {
            material.tilingOffset = Vector4(schema.scale.x, schema.scale.y, schema.offset.x, schema.offset.y)
        }
    }

    static func parseEngineResource(_ schema: GLTFTextureTransform?,
                                    _ material: PBRBaseMaterial,
                                    _ context: ParserContext) {
        if let schema = schema {
            material.tilingOffset = Vector4(schema.scale.x, schema.scale.y, schema.offset.x, schema.offset.y)
        }
    }
}