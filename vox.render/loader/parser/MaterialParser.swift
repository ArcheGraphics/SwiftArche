//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class MaterialParser: Parser {
    override func parse(_ context: ParserContext) {
        var materials: [Material] = []
        for i in 0..<context.glTFResource.gltf.materials.count {
            if (context.materialIndex != nil && context.materialIndex! != i) {
                continue;
            }
            let gltfMaterial = context.glTFResource.gltf.materials[i]

            let material: Material
            if gltfMaterial.extensions["KHR_materials_unlit"] != nil {
                material = PBRMaterial(context.engine);
            } else if gltfMaterial.extensions["KHR_materials_pbrSpecularGlossiness"] != nil {
                material = PBRMaterial(context.engine);
            } else {
                material = PBRMaterial(context.engine);
            }
            material.name = gltfMaterial.name ?? ""

        }
    }
}