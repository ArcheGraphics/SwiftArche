//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render
import ModelIO
import Metal

enum DecodeMode: Int {
    case Linear = 0
    case Gamma = 1
    case RGBE = 2
    case RGBM = 3
}

func createSphericalHarmonicsCoefficients(with texture: MDLTexture) -> SphericalHarmonics3 {
    let irradianceTexture = MDLTexture.irradianceTextureCube(with: texture, name: nil, dimensions: simd_make_int2(64, 64), roughness: 0)
    let lightProbe = MDLLightProbe(reflectiveTexture: texture, irradianceTexture: irradianceTexture)
    lightProbe.generateSphericalHarmonics(fromIrradiance: 2)
    var sh = SphericalHarmonics3()
    if let coefficients = lightProbe.sphericalHarmonicsCoefficients {
        (coefficients as NSData).getBytes(&sh.coefficients, length: 27 * MemoryLayout<Float>.stride)
    }
    return sh
}

func createSpecularTexture(_ engine: Engine, with cube: MTLTexture, _ decodeMode: DecodeMode = .Linear) -> MTLTexture? {
    let descriptor = MTLTextureDescriptor()
    descriptor.textureType = .typeCube
    descriptor.pixelFormat = cube.pixelFormat
    descriptor.width = cube.width
    descriptor.height = cube.height
    descriptor.mipmapLevelCount = cube.mipmapLevelCount
    descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.pixelFormatView.rawValue)
    let specularTexture = engine.textureLoader.makeTexture(descriptor)

    let functionConstants = MTLFunctionConstantValues()
    var decodeModeValue = decodeMode.rawValue
    functionConstants.setConstantValue(&decodeModeValue, type: .int, index: 0)
    let function = try! engine.library("app.shader").makeFunction(name: "build_specular", constantValues: functionConstants)
    let pipelineState = try! engine.device.makeComputePipelineState(function: function)
    if let commandBuffer = engine.commandQueue.makeCommandBuffer(),
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

func createMetallicRoughnessTexture(_ engine: Engine, with metallic: MTLTexture, and roughness: MTLTexture) -> MTLTexture? {
    let descriptor = MTLTextureDescriptor()
    descriptor.textureType = .type2D
    descriptor.pixelFormat = metallic.pixelFormat
    descriptor.width = metallic.width
    descriptor.height = metallic.height
    descriptor.usage = MTLTextureUsage(rawValue: metallic.usage.rawValue | MTLTextureUsage.shaderWrite.rawValue)
    let mergedTexture = engine.textureLoader.makeTexture(descriptor)

    let function = engine.library("app.shader").makeFunction(name: "build_metallicRoughness")
    let pipelineState = try! engine.device.makeComputePipelineState(function: function!)
    if let commandBuffer = engine.commandQueue.makeCommandBuffer(),
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
