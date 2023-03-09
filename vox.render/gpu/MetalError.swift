//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public enum MetalError {
    public enum MTLDeviceError: Error {
        case argumentEncoderCreationFailed
        case bufferCreationFailed
        case commandQueueCreationFailed
        case depthStencilStateCreationFailed
        case eventCreationFailed
        case fenceCreationFailed
        case heapCreationFailed
        case indirectCommandBufferCreationFailed
        case libraryCreationFailed
        case rasterizationRateMapCreationFailed
        case samplerStateCreationFailed
        case textureCreationFailed
        case textureViewCreationFailed
    }

    public enum MTLHeapError: Error {
        case bufferCreationFailed
        case textureCreationFailed
    }

    public enum MTLCommandQueueError: Error {
        case commandBufferCreationFailed
    }

    public enum MTLLibraryError: Error {
        case functionCreationFailed
    }

    public enum MTLTextureSerializationError: Error {
        case allocationFailed
        case dataAccessFailure
        case unsupportedPixelFormat
    }

    public enum MTLTextureError: Error {
        case imageCreationFailed
        case imageIncompatiblePixelFormat
        case incompatibleStorageMode
        case pixelBufferConversionFailed
    }

    public enum MTLResourceError: Error {
        case resourceUnavailable
    }

    public enum MTLBufferError: Error {
        case incompatibleData
    }

    public enum MTLPixelFormatError: Error {
        case incompatibleCVPixelFormat
    }
}
