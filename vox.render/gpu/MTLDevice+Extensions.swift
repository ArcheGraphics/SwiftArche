//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLDevice {
    func multisampleRenderTargetPair(width: Int, height: Int,
                                     pixelFormat: MTLPixelFormat,
                                     sampleCount: Int = 4) throws -> (main: MTLTexture,
                                                                      resolve: MTLTexture)
    {
        let mainDescriptor = MTLTextureDescriptor()
        mainDescriptor.textureType = .type2DMultisample
        mainDescriptor.sampleCount = sampleCount
        mainDescriptor.width = width
        mainDescriptor.height = height
        mainDescriptor.pixelFormat = pixelFormat
        mainDescriptor.usage = [.renderTarget, .shaderRead]

        let sampleDescriptor = MTLTextureDescriptor()
        sampleDescriptor.width = width
        sampleDescriptor.height = height
        sampleDescriptor.pixelFormat = pixelFormat
        sampleDescriptor.usage = [.shaderRead, .shaderWrite]

        guard let mainTex = makeTexture(descriptor: mainDescriptor),
              let sampleTex = makeTexture(descriptor: sampleDescriptor)
        else {
            throw MetalError.MTLDeviceError.textureCreationFailed
        }

        return (main: mainTex, resolve: sampleTex)
    }

    func maxTextureSize(desiredSize: MTLSize) -> MTLSize {
        let maxSide: Int
        if supportsOnly8K() {
            maxSide = 8192
        } else {
            maxSide = 16384
        }

        guard desiredSize.width > 0,
              desiredSize.height > 0
        else {
            return .zero
        }

        let aspectRatio = Float(desiredSize.width) / Float(desiredSize.height)
        if aspectRatio > 1 {
            let resultWidth = min(desiredSize.width, maxSide)
            let resultHeight = Float(resultWidth) / aspectRatio
            return MTLSize(width: resultWidth, height: Int(resultHeight.rounded()), depth: 0)
        } else {
            let resultHeight = min(desiredSize.height, maxSide)
            let resultWidth = Float(resultHeight) * aspectRatio
            return MTLSize(width: Int(resultWidth.rounded()), height: resultHeight, depth: 0)
        }
    }

    private func supportsOnly8K() -> Bool {
        #if targetEnvironment(macCatalyst)
            return !supportsFamily(.apple3)
        #elseif os(macOS)
            return false
        #else
            if #available(iOS 13.0, *) {
                return !supportsFamily(.apple3)
            } else {
                return !supportsFeatureSet(.iOS_GPUFamily3_v3)
            }
        #endif
    }
}
