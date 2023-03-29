//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

struct RenderCommandEncoderDescriptor {
    var label: String
    var renderTarget: MTLRenderPassDescriptor
    var commandBuffer: MTLCommandBuffer
}

extension RenderCommandEncoderDescriptor: ResourceRealize {
    public typealias actual_type = RenderCommandEncoder

    public func realize() -> RenderCommandEncoder? {
        RenderCommandEncoder(commandBuffer, renderTarget, label)
    }
}

class RenderCommandEncoderData: EmptyClassType {
    var output: Resource<RenderCommandEncoderDescriptor>!
    required init() {}
}
