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

    public func createSpecularTexture(with cube: MTLTexture, _ decodeMode: DecodeMode = .Linear) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .typeCube
        descriptor.pixelFormat = cube.pixelFormat
        descriptor.width = cube.width
        descriptor.height = cube.height
        descriptor.mipmapLevelCount = cube.mipmapLevelCount
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.pixelFormatView.rawValue)
        let specularTexture = makeTexture(descriptor)

        let functionConstants = MTLFunctionConstantValues()
        var decodeModeValue = decodeMode.rawValue
        functionConstants.setConstantValue(&decodeModeValue, type: .int, index: 0)
        let function = try! _engine.library.makeFunction(name: "build_specular", constantValues: functionConstants)
        let pipelineState = try! _engine.device.makeComputePipelineState(function: function)
        if let commandBuffer = _engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(cube, index: 0)
            for lod in 0..<cube.mipmapLevelCount {
                let textureView = specularTexture.makeTextureView(pixelFormat: cube.pixelFormat, textureType: .typeCube,
                        levels: lod..<lod + 1, slices: lod * 6..<lod * 6 + 6)
                commandEncoder.setTexture(textureView, index: 1)
                var roughness: Float = Float(lod) / Float(cube.mipmapLevelCount - 1)  // linear
                commandEncoder.setBytes(&roughness, length: MemoryLayout<Float>.stride, index: 0)

                let size = Int(Float(cube.width) / pow(2.0, Float(lod)))
                commandEncoder.dispatchThreads(MTLSizeMake(size / 16, size / 16, 6),
                        threadsPerThreadgroup: MTLSizeMake(16, 16, 1))
            }
        }
        return specularTexture
    }

    public func createMetallicRoughnessTexture(with metallic: MTLTexture, and roughness: MTLTexture) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2D
        descriptor.pixelFormat = metallic.pixelFormat
        descriptor.width = metallic.width
        descriptor.height = metallic.height
        descriptor.usage = MTLTextureUsage(rawValue: metallic.usage.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        let mergedTexture = makeTexture(descriptor)

        let function = _engine.library.makeFunction(name: "build_metallicRoughness")
        let pipelineState = try! _engine.device.makeComputePipelineState(function: function!)
        if let commandBuffer = _engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(metallic, index: 0)
            commandEncoder.setTexture(roughness, index: 1)
            commandEncoder.setTexture(mergedTexture, index: 2)

            let size = metallic.width
            commandEncoder.dispatchThreads(MTLSizeMake(size / min(size, 16), size / min(size, 16), 1),
                    threadsPerThreadgroup: MTLSizeMake(min(size, 16), min(size, 16), 1))
            commandEncoder.endEncoding()

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        return mergedTexture
    }
}
