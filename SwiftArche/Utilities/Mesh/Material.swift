//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

struct Material {
    var baseColor: MTLTexture
    var normal: MTLTexture
    var specular: MTLTexture

    init(_ mdlMaterial: MDLMaterial, textureLoader: MTKTextureLoader) {

        baseColor = Material.makeTexture(from: mdlMaterial,
                materialSemantic: .baseColor,
                textureLoader: textureLoader)

        normal = Material.makeTexture(from: mdlMaterial,
                materialSemantic: .tangentSpaceNormal,
                textureLoader: textureLoader)

        specular = Material.makeTexture(from: mdlMaterial,
                materialSemantic: .specular,
                textureLoader: textureLoader)
    }

    static private func makeTexture(from material: MDLMaterial,
                                    materialSemantic: MDLMaterialSemantic,
                                    textureLoader: MTKTextureLoader) -> MTLTexture {

        var newTexture: MTLTexture!

        for property in material.properties(with: materialSemantic) {
            // Load the textures with shader read using private storage
            let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .textureStorageMode: MTLStorageMode.private.rawValue]

            switch property.type {
            case .string:
                if let stringValue = property.stringValue {

                    // If not texture has been fround by interpreting the URL as a path,  interpret
                    // string as an asset catalog name and attempt to load it with
                    //  -[MTKTextureLoader newTextureWithName:scaleFactor:bundle:options::error:]
                    // If a texture with the by interpreting the URL as an asset catalog name
                    if let texture = try? textureLoader.newTexture(name: stringValue, scaleFactor: 1.0, bundle: nil, options: textureLoaderOptions) {
                        newTexture = texture
                    }
                }
            case .URL:
                if let textureURL = property.urlValue {
                    // Attempt to load the texture from the file system
                    // If the texture has been found for a material using the string as a file path name...
                    if let texture = try? textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions) {
                        newTexture = texture
                    }
                }
            default:
                // If we did not find the texture by interpreting it as a file path or as an asset name in the asset catalog, something went wrong
                // (Perhaps the file was missing or misnamed in the asset catalog, model/material file, or file system)
                // Depending on how the Metal render pipeline use with this submesh is implemented, this condition can be handled more gracefully.
                // The app could load a dummy texture that will look okay when set with the pipeline or ensure that the pipelines rendering
                // this submesh does not require a material with this property.

                fatalError("Texture data for material property not found.")
            }
        }
        return newTexture
    }
}
