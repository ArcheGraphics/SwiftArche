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

    /// static method to load texture from name of image.
    /// - Parameter imageName: name of image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    public func loadTexture(imageName: String) throws -> MTLTexture? {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .generateMipmaps: NSNumber(booleanLiteral: true)]
        let fileExtension =
                URL(fileURLWithPath: imageName).pathExtension.isEmpty ?
                        "png" : nil
        guard let url = Bundle.main.url(forResource: imageName,
                withExtension: fileExtension)
        else {
            let texture = try? textureLoader.newTexture(name: imageName,
                    scaleFactor: 1.0,
                    bundle: Bundle.main, options: nil)
            if texture == nil {
                print("WARNING: Texture not found: \(imageName)")
            }
            return texture
        }

        let texture = try textureLoader.newTexture(URL: url,
                options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }

    /// static method to load texture from a instance of MDLTexture
    /// - Parameter texture: a source of texel data
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    public func loadTexture(texture: MDLTexture) throws -> MTLTexture? {
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
                [.origin: MTKTextureLoader.Origin.topLeft,
                 .SRGB: false,
                 .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
                 .generateMipmaps: NSNumber(booleanLiteral: true)]
        let texture = try? textureLoader.newTexture(texture: texture,
                options: textureLoaderOptions)
        return texture
    }

    /// static method to load cube texture from name of image.
    /// - Parameter imageName: name of cube image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    public func loadCubeTexture(imageName: String) throws -> MTLTexture {
        if let texture = MDLTexture(cubeWithImagesNamed: [imageName]) {
            let options: [MTKTextureLoader.Option: Any] =
                    [.origin: MTKTextureLoader.Origin.topLeft,
                     .SRGB: false,
                     .generateMipmaps: NSNumber(booleanLiteral: false)]
            return try textureLoader.newTexture(texture: texture, options: options)
        }
        let texture = try textureLoader.newTexture(name: imageName, scaleFactor: 1.0,
                bundle: .main)
        return texture
    }

    /// static method to load up the textures into a temporary array of MTLTextures.
    /// - Parameter textureNames: lists about name of image
    /// - Throws: a pointer to an NSError object if an error occurred, or nil if the texture was fully loaded and initialized.
    /// - Returns: a fully loaded and initialized Metal texture, or nil if an error occurred.
    public func loadTextureArray(textureNames: [String]) -> MTLTexture? {
        var textures: [MTLTexture] = []
        for textureName in textureNames {
            do {
                if let texture = try self.loadTexture(imageName: textureName) {
                    textures.append(texture)
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        guard textures.count > 0 else {
            return nil
        }
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2DArray
        descriptor.pixelFormat = textures[0].pixelFormat
        descriptor.width = textures[0].width
        descriptor.height = textures[0].height
        descriptor.arrayLength = textures.count
        let arrayTexture = _engine.device.makeTexture(descriptor: descriptor)!
        let commandBuffer = _engine.commandQueue.makeCommandBuffer()!
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        let origin = MTLOrigin(x: 0, y: 0, z: 0)
        let size = MTLSize(width: arrayTexture.width,
                height: arrayTexture.height, depth: 1)
        for (index, texture) in textures.enumerated() {
            blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                    sourceOrigin: origin, sourceSize: size,
                    to: arrayTexture, destinationSlice: index,
                    destinationLevel: 0, destinationOrigin: origin)
        }
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return arrayTexture
    }

    /// configure a texture descriptor and create a texture using that descriptor.
    /// - Parameters:
    ///   - size: size of the 2D texture image
    ///   - label: a string that identifies the resource
    ///   - pixelFormat: the format describing how every pixel on the texture image is stored
    ///   - usage: options that determine how you can use the texture
    /// - Returns: a fully loaded and initialized Metal texture
    public func buildTexture(size: CGSize,
                             label: String,
                             pixelFormat: MTLPixelFormat,
                             usage: MTLTextureUsage) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                width: Int(size.width),
                height: Int(size.height),
                mipmapped: false)
        descriptor.sampleCount = 1
        descriptor.storageMode = .private
        descriptor.textureType = .type2D
        descriptor.usage = usage
        guard let texture = _engine.device.makeTexture(descriptor: descriptor) else {
            fatalError("Texture not created")
        }
        texture.label = label
        return texture
    }
}