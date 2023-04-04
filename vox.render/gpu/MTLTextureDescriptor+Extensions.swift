//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLTextureDescriptor {
    func makeCopy() -> MTLTextureDescriptor {
        let copy = MTLTextureDescriptor()
        copy.pixelFormat = pixelFormat
        copy.width = width
        copy.height = height
        copy.depth = depth
        copy.mipmapLevelCount = mipmapLevelCount
        copy.sampleCount = sampleCount
        copy.arrayLength = arrayLength
        copy.resourceOptions = resourceOptions
        copy.cpuCacheMode = cpuCacheMode
        copy.storageMode = storageMode
        copy.usage = usage

        if #available(iOS 13.0, macOS 10.15, *) {
            copy.hazardTrackingMode = hazardTrackingMode
            copy.allowGPUOptimizedContents = allowGPUOptimizedContents
            copy.swizzle = swizzle
        }

        if #available(iOS 15.0, macOS 12.5, *) {
            copy.compressionType = compressionType
        }

        return copy
    }
}

extension MTLTextureDescriptor: ResourceRealize {
    public typealias actual_type = MTLTexture

    public var size: Int {
        let sizeAndAlign = Engine.device.heapTextureSizeAndAlign(descriptor: self)
        return alignUp(size: sizeAndAlign.size, align: sizeAndAlign.align)
    }

    public func realize(with heap: MTLHeap?) -> MTLTexture? {
        heap!.makeTexture(descriptor: self)
    }

    public func derealize(resource: actual_type) {
        resource.makeAliasable()
    }
}
