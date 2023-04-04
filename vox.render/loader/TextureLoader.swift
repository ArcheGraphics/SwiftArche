//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal
import MetalKit

public class TextureLoader {
    public let textureLoader: MTKTextureLoader = .init(device: Engine.device)

    /// configure a texture descriptor and create a texture using that descriptor.
    /// - Parameter descriptor: Texture descriptor
    /// - Returns: Texture
    public func makeTexture(_ descriptor: MTLTextureDescriptor) -> MTLTexture {
        guard let texture = Engine.device.makeTexture(descriptor: descriptor) else {
            fatalError("Texture not created")
        }
        return texture
    }

    public func loadTexture(with name: String, scaleFactor: CGFloat = 1.0, bundle: Bundle? = nil,
                            textureLoaderOptions: [MTKTextureLoader.Option: Any] = [:]) throws -> MTLTexture?
    {
        var textureLoaderOptions = textureLoaderOptions
        if textureLoaderOptions.isEmpty {
            let usage: MTLTextureUsage = [MTLTextureUsage.pixelFormatView, MTLTextureUsage.shaderRead]
            textureLoaderOptions = [.origin: MTKTextureLoader.Origin.topLeft,
                                    .generateMipmaps: NSNumber(booleanLiteral: true),
                                    .textureUsage: NSNumber(value: usage.rawValue)]
        }
        let texture = try textureLoader.newTexture(name: name, scaleFactor: scaleFactor,
                                                   bundle: bundle, options: textureLoaderOptions)
        return texture
    }

    /// load texture from url of image.
    /// - Parameters:
    ///   - url: URL
    ///   - textureLoaderOptions: MTKTextureLoader.Option
    /// - Returns: Texture
    /// - Throws: none
    public func loadTexture(with url: URL, _ textureLoaderOptions: [MTKTextureLoader.Option: Any] = [:]) throws -> MTLTexture? {
        var textureLoaderOptions = textureLoaderOptions
        if textureLoaderOptions.isEmpty {
            let usage: MTLTextureUsage = [MTLTextureUsage.pixelFormatView, MTLTextureUsage.shaderRead]
            textureLoaderOptions = [.origin: MTKTextureLoader.Origin.topLeft,
                                    .generateMipmaps: NSNumber(booleanLiteral: true),
                                    .textureUsage: NSNumber(value: usage.rawValue)]
        }
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        return texture
    }

    /// static method to load texture from a instance of MDLTexture
    /// - Parameters:
    ///   - texture: a source of texel data
    ///   - textureLoaderOptions: MTKTextureLoader.Option
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    public func loadTexture(with texture: MDLTexture, _ textureLoaderOptions: [MTKTextureLoader.Option: Any] = [:]) throws -> MTLTexture? {
        var textureLoaderOptions = textureLoaderOptions
        if textureLoaderOptions.isEmpty {
            let usage: MTLTextureUsage = [MTLTextureUsage.pixelFormatView, MTLTextureUsage.shaderRead]
            textureLoaderOptions = [.origin: MTKTextureLoader.Origin.topLeft,
                                    .generateMipmaps: NSNumber(booleanLiteral: true),
                                    .textureUsage: NSNumber(value: usage.rawValue)]
        }
        let texture = try? textureLoader.newTexture(texture: texture, options: textureLoaderOptions)
        return texture
    }

    public func loadHDR(with name: String) -> MTLTexture? {
        var error: NSError?
        return texture_from_radiance_file(name, Engine.device, &error)
    }
}
