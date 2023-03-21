//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Metal

public class IBLBaker {
    public var hdr: MTLTexture!
    public var cubeMap: MTLTexture!
    public var specularTexture: MTLTexture!
    public var shBuffer: BufferView!

    public func bake(_ scene: Scene, with hdr: MTLTexture, size: Int, level: Int) {
        self.hdr = hdr

        var descriptor = MTLTextureDescriptor()
        descriptor.textureType = .typeCube
        descriptor.pixelFormat = .rgba16Float
        descriptor.width = size
        descriptor.height = size
        descriptor.mipmapLevelCount = level;
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        cubeMap = Engine.textureLoader.makeTexture(descriptor)

        descriptor = MTLTextureDescriptor()
        descriptor.textureType = .typeCube
        descriptor.pixelFormat = cubeMap.pixelFormat
        descriptor.width = cubeMap.width
        descriptor.height = cubeMap.height
        descriptor.mipmapLevelCount = cubeMap.mipmapLevelCount
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        specularTexture = Engine.textureLoader.makeTexture(descriptor)

        // first 27 is parameter, the last is scale
        shBuffer = BufferView(device: Engine.device, count: 3 * 9 + 1, stride: MemoryLayout<Float>.stride)

        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            _createCubemap(commandBuffer);
            _createSpecularTexture(commandBuffer);
            _createSphericalHarmonicsCoefficients(commandBuffer);
            commandBuffer.addCompletedHandler { [specularTexture, shBuffer] _ in
                let ambientLight = AmbientLight();
                ambientLight.specularTexture = specularTexture
                ambientLight.diffuseSphericalHarmonics = shBuffer
                ambientLight.diffuseMode = DiffuseMode.SphericalHarmonics
                scene.ambientLight = ambientLight
            }
            commandBuffer.commit()
        }
    }

    private func _createSpecularTexture(_ commandBuffer: MTLCommandBuffer) {
        let function = Engine.library("app.shader").makeFunction(name: "build_specular")!
        let pipelineState = try! Engine.device.makeComputePipelineState(function: function)
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(cubeMap, index: 0)
            for lod in 0..<specularTexture.mipmapLevelCount {
                let textureView = specularTexture.makeTextureView(pixelFormat: specularTexture.pixelFormat, textureType: .typeCube,
                        levels: lod..<lod + 1, slices: 0..<6)
                commandEncoder.setTexture(textureView, index: 1)
                var roughness: Float = Float(lod) / Float(specularTexture.mipmapLevelCount - 1)  // linear
                commandEncoder.setBytes(&roughness, length: MemoryLayout<Float>.stride, index: 0)

                let size = Int(specularTexture.width)
                let w = pipelineState.threadExecutionWidth
                let h = pipelineState.maxTotalThreadsPerThreadgroup / w
                commandEncoder.dispatchThreads(MTLSizeMake(size, size, 6),
                        threadsPerThreadgroup: MTLSizeMake(w, h, 1))
            }
            commandEncoder.endEncoding()
        }
    }

    private func _createSphericalHarmonicsCoefficients(_ commandBuffer: MTLCommandBuffer) {
        let function = Engine.library("app.shader").makeFunction(name: "compute_sh")
        let pipelineState = try! Engine.device.makeComputePipelineState(function: function!)
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setBuffer(shBuffer.buffer, offset: 0, index: 0)
            commandEncoder.setTexture(cubeMap, index: 0)

            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            commandEncoder.dispatchThreads(MTLSizeMake(9, 6, 1),
                    threadsPerThreadgroup: MTLSizeMake(w, h, 1))
            commandEncoder.endEncoding()
        }
    }

    private func _createCubemap(_ commandBuffer: MTLCommandBuffer) {
        let function = Engine.library("app.shader").makeFunction(name: "cubemap_generator")
        let pipelineState = try! Engine.device.makeComputePipelineState(function: function!)
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(hdr, index: 0)
            commandEncoder.setTexture(cubeMap, index: 1)

            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            commandEncoder.dispatchThreads(MTLSizeMake(cubeMap.width, cubeMap.height, 6),
                    threadsPerThreadgroup: MTLSizeMake(w, h, 1))
            commandEncoder.endEncoding()
        }

        if cubeMap.mipmapLevelCount > 1, let commandEncoder = commandBuffer.makeBlitCommandEncoder() {
            commandEncoder.generateMipmaps(for: cubeMap)
            commandEncoder.endEncoding()
        }
    }
}
