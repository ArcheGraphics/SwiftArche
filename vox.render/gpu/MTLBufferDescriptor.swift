//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public struct MTLBufferDescriptor {
    public var count: Int
    public var stride: Int
    public var options: MTLResourceOptions = [.storageModePrivate]
    public var label: String? = nil
    
    public init(count: Int, stride: Int) {
        self.count = count
        self.stride = stride
    }
}

extension MTLBufferDescriptor: ResourceRealize {
    public typealias actual_type = MTLBuffer
    
    public var size: Int {
        let sizeAndAlign = Engine.device.heapBufferSizeAndAlign(length: stride * count, options: options)
        return alignUp(size: sizeAndAlign.size, align: sizeAndAlign.align)
    }

    public func realize(with heap: MTLHeap?) -> MTLBuffer? {
        let buffer = heap!.makeBuffer(length: stride * count, options: options)
        buffer?.label = label
        return buffer
    }
    
    public func derealize(resource: MTLBuffer) {
        resource.makeAliasable()
    }
}
