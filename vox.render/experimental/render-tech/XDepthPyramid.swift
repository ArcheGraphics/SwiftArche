//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class XDepthPyramid {
    /// Device from initialization.
    private var _device: MTLDevice
    /// Depth downsampling pipeline state.
    private var _pipelineState: MTLComputePipelineState

    /// Initializes this helper, pre-allocating objects from the device.
    init(with device: MTLDevice, library: MTLLibrary) {
        _device = device
        _pipelineState = newComputePipelineState(library: library, functionName: "depthPyramid",
                label: "DepthPyramidGeneration", functionConstants: nil)!
    }

    /// Generates the depth pyramid texture from the specified depth texture.
    ///  Supports both being the same texture.
    func generate(pyramidTexture: MTLTexture,
                  depthTexture: MTLTexture,
                  encoder: MTLComputeCommandEncoder) {
        encoder.pushDebugGroup("Depth pyramid generation")
        encoder.setComputePipelineState(_pipelineState)

        var srcMip = depthTexture
        var startMip = 0
        if (depthTexture === pyramidTexture) {
            srcMip = pyramidTexture.makeTextureView(pixelFormat: .r32Float, textureType: .type2D, levels: 0..<1, slices: 0..<1)!
            startMip = 1 // Skip first mip
        }
        for i in startMip..<pyramidTexture.mipmapLevelCount {
            let dstMip = pyramidTexture.makeTextureView(pixelFormat: .r32Float, textureType: .type2D, levels: i..<i + 1, slices: 0..<1)!
            dstMip.label = "PyramidMipLevel\(i)"
            encoder.setTexture(srcMip, index: 0)
            encoder.setTexture(dstMip, index: 1)

            var sizes = simd_uint4(UInt32(srcMip.width), UInt32(srcMip.height), 0, 0)
            encoder.setBytes(&sizes, length: MemoryLayout<simd_uint4>.stride, index: Int(XBufferIndexDepthPyramidSize.rawValue))
            encoder.dispatchThreadgroups(
                    divideRoundUp(numerator: MTLSizeMake(dstMip.width, dstMip.height, 1),
                            denominator: MTLSize(width: 8, height: 8, depth: 1)),
                    threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
            srcMip = dstMip
        }

        encoder.popDebugGroup()
    }

    /// Checks if the specified pyramid texture is valid for the depth texture.
    ///  If not, it should be allocated with allocatePyramidTextureFromDepth.
    static func isPyramidTextureValid(for pyramidTexture: MTLTexture?, depthTexture: MTLTexture) -> Bool {
        let validPyramid = (pyramidTexture != nil &&
                pyramidTexture!.width == depthTexture.width / 2 &&
                pyramidTexture!.height == depthTexture.height / 2)
        return validPyramid
    }

    /// Allocates a pyramid texture based on the depth texture it will downsample.
    static func allocatePyramidTexture(from depthTexture: MTLTexture, device: MTLDevice) -> MTLTexture {
        let depthTexDesc = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .r32Float,
                width: depthTexture.width / 2,
                height: depthTexture.height / 2,
                mipmapped: true)
        if (depthTexture.textureType == .type2DArray) {
            depthTexDesc.textureType = .type2DArray
            depthTexDesc.arrayLength = depthTexture.arrayLength
        }
        depthTexDesc.storageMode = .private
        depthTexDesc.usage = [.shaderWrite, .shaderRead, .pixelFormatView]

        return device.makeTexture(descriptor: depthTexDesc)!
    }
}
