//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal.MTLHeap

// Returns a size of the 'inSize' aligned to 'align' as long as align is a power of 2
public func alignUp(size: Int, align: Int) -> Int {
    #if DEBUG
        precondition(((align - 1) & align) == 0, "Align must be a power of two")
    #endif

    let alignmentMask = align - 1

    return (size + alignmentMask) & ~alignmentMask
}

public extension MTLSizeAndAlign {
    func combined(with sizeAndAlign: MTLSizeAndAlign) -> MTLSizeAndAlign {
        let requiredAlignment = max(align, sizeAndAlign.align)
        let selfAligned = alignUp(size: size, align: requiredAlignment)
        let otherAligned = alignUp(size: sizeAndAlign.size, align: requiredAlignment)

        return MTLSizeAndAlign(size: selfAligned + otherAligned, align: requiredAlignment)
    }
}

public extension Sequence where Element == MTLTextureDescriptor {
    func heapSizeAndAlignCombined(on device: MTLDevice) -> MTLSizeAndAlign {
        reduce(MTLSizeAndAlign(size: 0, align: 0)) {
            $0.combined(with: device.heapTextureSizeAndAlign(descriptor: $1))
        }
    }
}
