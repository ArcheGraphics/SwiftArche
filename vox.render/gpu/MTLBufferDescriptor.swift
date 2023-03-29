//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public struct MTLBufferDescriptor {
    public var count: Int
    public var stride: Int
    public var options: MTLResourceOptions = []
    public var label: String? = nil
    
    public init(count: Int, stride: Int) {
        self.count = count
        self.stride = stride
    }
}

extension MTLBufferDescriptor: ResourceRealize {
    public typealias actual_type = BufferView

    public func realize() -> BufferView? {
        BufferView(device: Engine.device, count: count, stride: stride, label: label, options: options)
    }
}
