//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class MaterialParser: Parser {
    override func parse(_ context: ParserContext) {
        var materials: [Material] = []
        let glTFResource = context.glTFResource!
        for i in 0 ..< glTFResource.gltf.materials.count {
            if context.materialIndex != nil && context.materialIndex! != i {
                continue
            }
            let gltfMaterial = glTFResource.gltf.materials[i]
            let mtl: BaseMaterial

            if gltfMaterial.isUnlit {
                let material = UnlitMaterial()
                material.name = gltfMaterial.name ?? ""
                mtl = material
            } else {
                let pbrMtl: PBRBaseMaterial
                if gltfMaterial.specularGlossiness != nil {
                    let material = KHR_materials_pbrSpecularGlossiness.createEngineResource(gltfMaterial.specularGlossiness!, context)
                    mtl = material
                    pbrMtl = material
                } else {
                    let material = PBRMaterial()
                    mtl = material
                    pbrMtl = material
                }

                if let clearcoat = gltfMaterial.clearcoat {
                    KHR_materials_clearcoat.parseEngineResource(clearcoat, pbrMtl, context)
                }

                if let pbrMetallicRoughness = gltfMaterial.metallicRoughness {
                    pbrMtl.baseColor = Color(
                        Color.linearToGammaSpace(value: pbrMetallicRoughness.baseColorFactor.x),
                        Color.linearToGammaSpace(value: pbrMetallicRoughness.baseColorFactor.y),
                        Color.linearToGammaSpace(value: pbrMetallicRoughness.baseColorFactor.z),
                        pbrMetallicRoughness.baseColorFactor.w
                    )
                    if let baseColorTexture = pbrMetallicRoughness.baseColorTexture,
                       let samplers = glTFResource.samplers
                    {
                        pbrMtl.baseTexture = glTFResource.textures![baseColorTexture.index]
                        if let sampler = samplers[baseColorTexture.index] {
                            pbrMtl.baseSampler = sampler
                        }
                        KHR_texture_transform.parseEngineResource(baseColorTexture.transform, pbrMtl, context)
                    }
                    if let pbrMtl = pbrMtl as? PBRMaterial {
                        pbrMtl.roughness = pbrMetallicRoughness.roughnessFactor
                        pbrMtl.metallic = pbrMetallicRoughness.metallicFactor
                        if let metallicRoughnessTexture = pbrMetallicRoughness.metallicRoughnessTexture,
                           let samplers = glTFResource.samplers
                        {
                            pbrMtl.roughnessMetallicTexture = glTFResource.textures![metallicRoughnessTexture.index]
                            if let sampler = samplers[metallicRoughnessTexture.index] {
                                pbrMtl.roughnessMetallicSampler = sampler
                            }
                            KHR_texture_transform.parseEngineResource(metallicRoughnessTexture.transform, pbrMtl, context)
                        }
                    }
                }

//                if let emissiveTexture = gltfMaterial.emissive,
//                    let samplers = glTFResource.samplers {
//                    pbrMtl.emissiveTexture = glTFResource.textures![emissiveTexture.index]
//                    if let sampler = samplers[emissiveTexture.index] {
//                        pbrMtl.setEmissiveSampler(value: sampler)
//                    }
//                    KHR_texture_transform.parseEngineResource(emissiveTexture.transform, pbrMtl, context)
//                }
//                pbrMtl.emissiveColor = Color(
//                        Color.linearToGammaSpace(value: gltfMaterial.emissiveFactor.x),
//                        Color.linearToGammaSpace(value: gltfMaterial.emissiveFactor.y),
//                        Color.linearToGammaSpace(value: gltfMaterial.emissiveFactor.z),
//                        1
//                )

                if let normalTexture = gltfMaterial.normalTexture,
                   let samplers = glTFResource.samplers
                {
                    pbrMtl.normalTextureIntensity = normalTexture.scale
                    pbrMtl.normalTexture = glTFResource.textures![normalTexture.index]
                    if let sampler = samplers[normalTexture.index] {
                        pbrMtl.normalSampler = sampler
                    }
                    KHR_texture_transform.parseEngineResource(normalTexture.transform, pbrMtl, context)
                }

                if let occlusionTexture = gltfMaterial.occlusionTexture,
                   let samplers = glTFResource.samplers
                {
                    if occlusionTexture.texCoord == TextureCoordinate.UV1.rawValue {
                        pbrMtl.occlusionTextureCoord = TextureCoordinate.UV1
                    } else if occlusionTexture.texCoord > TextureCoordinate.UV1.rawValue {
                        logger.warning("Occlusion texture uv coordinate must be UV0 or UV1.")
                    }

                    pbrMtl.occlusionTextureIntensity = occlusionTexture.scale
                    pbrMtl.occlusionTexture = glTFResource.textures![occlusionTexture.index]
                    if let sampler = samplers[occlusionTexture.index] {
                        pbrMtl.occlusionSampler = sampler
                    }
                    KHR_texture_transform.parseEngineResource(occlusionTexture.transform, pbrMtl, context)
                }
            }

            mtl.name = gltfMaterial.name ?? ""
            if gltfMaterial.isDoubleSided {
                mtl.setRenderFace(at: 0, .Double)
            } else {
                mtl.setRenderFace(at: 0, .Front)
            }

            switch gltfMaterial.alphaMode {
            case .blend:
                mtl.isTransparent = true
            case .mask:
                mtl.alphaCutoff = gltfMaterial.alphaCutoff
            case .opaque:
                mtl.isTransparent = false
                break
            @unknown default:
                break
            }
            materials.append(mtl)
        }
        context.glTFResource.materials = materials
    }
}
