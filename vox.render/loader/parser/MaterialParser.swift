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
            if gltfMaterial.isUnlit {
                material = UnlitMaterial(context.engine, gltfMaterial.name ?? "");
            } else if gltfMaterial.specularGlossiness != nil {
                material = KHR_materials_pbrSpecularGlossiness.createEngineResource(gltfMaterial.specularGlossiness!, context)
            } else {
                material = PBRMaterial(context.engine);
            }
            material.name = gltfMaterial.name ?? ""

        }
    }
}