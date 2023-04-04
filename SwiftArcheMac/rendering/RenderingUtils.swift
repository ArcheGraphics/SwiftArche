//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal
import ModelIO
import vox_render

func createSphericalHarmonicsCoefficients(with cube: MTLTexture) -> BufferView {
    // first 27 is parameter, the last is scale
    let bufferView = BufferView(count: 28, stride: MemoryLayout<Float>.stride)

    let function = Engine.library("app.shader").makeFunction(name: "compute_sh")
    let pipelineState = try! Engine.device.makeComputePipelineState(function: function!)
    if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
       let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    {
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(bufferView.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(cube, index: 0)

        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        commandEncoder.dispatchThreads(MTLSizeMake(9, 6, 1),
                                       threadsPerThreadgroup: MTLSizeMake(w, h, 1))
        commandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    return bufferView
}

func createSpecularTexture(with cube: MTLTexture, format: MTLPixelFormat,
                           lodStart: Int = 0, lodEnd: Int = -1) -> MTLTexture?
{
    let mipmapEnd = (lodEnd != -1 ? lodEnd : cube.mipmapLevelCount)
    let descriptor = MTLTextureDescriptor()
    descriptor.textureType = .typeCube
    descriptor.pixelFormat = format
    descriptor.width = cube.width >> lodStart
    descriptor.height = cube.height >> lodStart
    descriptor.mipmapLevelCount = mipmapEnd - lodStart
    descriptor.usage = [.shaderRead, .shaderWrite]
    let specularTexture = Engine.textureLoader.makeTexture(descriptor)

    let function = Engine.library("app.shader").makeFunction(name: "build_specular")!
    let pipelineState = try! Engine.device.makeComputePipelineState(function: function)
    if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
       let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    {
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(cube, index: 0)
        for lod in 0 ..< specularTexture.mipmapLevelCount {
            let textureView = specularTexture.makeTextureView(pixelFormat: format, textureType: .typeCube,
                                                              levels: lod ..< lod + 1, slices: 0 ..< 6)
            commandEncoder.setTexture(textureView, index: 1)
            var roughness: Float = .init(lod) / Float(specularTexture.mipmapLevelCount - 1) // linear
            commandEncoder.setBytes(&roughness, length: MemoryLayout<Float>.stride, index: 0)

            let size = Int(descriptor.width)
            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            commandEncoder.dispatchThreads(MTLSizeMake(size, size, 6),
                                           threadsPerThreadgroup: MTLSizeMake(w, h, 1))
        }
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    return specularTexture
}

func createMetallicRoughnessTexture(with metallic: MTLTexture, and roughness: MTLTexture) -> MTLTexture? {
    let descriptor = MTLTextureDescriptor()
    descriptor.textureType = .type2D
    descriptor.pixelFormat = metallic.pixelFormat
    descriptor.width = metallic.width
    descriptor.height = metallic.height
    descriptor.usage = [metallic.usage, .shaderWrite]
    let mergedTexture = Engine.textureLoader.makeTexture(descriptor)

    let function = Engine.library("app.shader").makeFunction(name: "build_metallicRoughness")
    let pipelineState = try! Engine.device.makeComputePipelineState(function: function!)
    if let commandBuffer = Engine.commandQueue.makeCommandBuffer(),
       let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    {
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(metallic, index: 0)
        commandEncoder.setTexture(roughness, index: 1)
        commandEncoder.setTexture(mergedTexture, index: 2)

        let w = pipelineState.threadExecutionWidth
        let h = pipelineState.maxTotalThreadsPerThreadgroup / w
        commandEncoder.dispatchThreads(MTLSizeMake(metallic.width, metallic.height, 1),
                                       threadsPerThreadgroup: MTLSizeMake(w, h, 1))
        commandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    return mergedTexture
}

func createCubemap(with hdr: MTLTexture, size: Int, level: Int) -> MTLTexture {
    let descriptor = MTLTextureDescriptor()
    descriptor.textureType = .typeCube
    descriptor.pixelFormat = .rgba16Float
    descriptor.width = size
    descriptor.height = size
    descriptor.mipmapLevelCount = level
    descriptor.usage = [.shaderRead, .shaderWrite]
    let cubeMap = Engine.textureLoader.makeTexture(descriptor)

    let function = Engine.library("app.shader").makeFunction(name: "cubemap_generator")
    let pipelineState = try! Engine.device.makeComputePipelineState(function: function!)
    if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(hdr, index: 0)
            commandEncoder.setTexture(cubeMap, index: 1)

            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            commandEncoder.dispatchThreads(MTLSizeMake(size, size, 6),
                                           threadsPerThreadgroup: MTLSizeMake(w, h, 1))
            commandEncoder.endEncoding()
        }

        if level > 1, let commandEncoder = commandBuffer.makeBlitCommandEncoder() {
            commandEncoder.generateMipmaps(for: cubeMap)
            commandEncoder.endEncoding()
        }

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    return cubeMap
}

/// load from xcassets
func loadAmbientLight(withLDR cubeMap: MTLTexture, format: MTLPixelFormat = .rgba8Unorm,
                      lodStart: Int = 0, lodEnd: Int = -1) -> AmbientLight
{
    let ambientLight = AmbientLight()
    ambientLight.specularTexture = createSpecularTexture(with: cubeMap, format: format, lodStart: lodStart, lodEnd: lodEnd)
    ambientLight.diffuseSphericalHarmonics = createSphericalHarmonicsCoefficients(with: cubeMap)
    ambientLight.diffuseMode = DiffuseMode.SphericalHarmonics
    return ambientLight
}

/// no need lod because it control by createCubemap, and no need format which is not srgb
func loadAmbientLight(withHDR cubeMap: MTLTexture) -> AmbientLight {
    let ambientLight = AmbientLight()
    ambientLight.specularTexture = createSpecularTexture(with: cubeMap, format: cubeMap.pixelFormat)
    ambientLight.diffuseSphericalHarmonics = createSphericalHarmonicsCoefficients(with: cubeMap)
    ambientLight.diffuseMode = DiffuseMode.SphericalHarmonics
    return ambientLight
}

/// no need format which is not srgb
func loadAmbientLight(withPCG cubeMap: MTLTexture, lodStart: Int = 0, lodEnd: Int = -1) -> AmbientLight {
    let ambientLight = AmbientLight()
    ambientLight.specularTexture = createSpecularTexture(with: cubeMap, format: cubeMap.pixelFormat,
                                                         lodStart: lodStart, lodEnd: lodEnd)
    ambientLight.diffuseSphericalHarmonics = createSphericalHarmonicsCoefficients(with: cubeMap)
    ambientLight.diffuseMode = DiffuseMode.SphericalHarmonics
    return ambientLight
}
