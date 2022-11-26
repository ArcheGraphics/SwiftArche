//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import MetalKit

public class TextureLoader {
    private var _engine: Engine

    public let textureLoader: MTKTextureLoader

    init(_ engine: Engine) {
        _engine = engine
        textureLoader = MTKTextureLoader(device: _engine.device)
    }

    /// configure a texture descriptor and create a texture using that descriptor.
    /// - Parameter descriptor: Texture descriptor
    /// - Returns: Texture
    public func makeTexture(_ descriptor: MTLTextureDescriptor) -> MTLTexture {
        guard let texture = _engine.device.makeTexture(descriptor: descriptor) else {
            fatalError("Texture not created")
        }
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
            textureLoaderOptions = [.origin: MTKTextureLoader.Origin.topLeft,
                                    .SRGB: false,
                                    .generateMipmaps: NSNumber(booleanLiteral: true)]
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
            textureLoaderOptions = [.origin: MTKTextureLoader.Origin.topLeft,
                                    .SRGB: false,
                                    .generateMipmaps: NSNumber(booleanLiteral: true)]
        }
        let texture = try? textureLoader.newTexture(texture: texture, options: textureLoaderOptions)
        return texture
    }

    public func createSphericalHarmonicsCoefficients(with texture: MDLTexture) -> [Float] {
        let irradianceTexture = MDLTexture.irradianceTextureCube(with: texture, name: nil, dimensions: simd_make_int2(64, 64), roughness: 0)
        let lightProbe = MDLLightProbe(reflectiveTexture: texture, irradianceTexture: irradianceTexture)
        lightProbe.generateSphericalHarmonics(fromIrradiance: 2)
        var sh = [Float](repeating: 0, count: 27)
        if let coefficients = lightProbe.sphericalHarmonicsCoefficients {
            (coefficients as NSData).getBytes(&sh, length: 27 * MemoryLayout<Float>.stride)
        }
        return sh
    }
}