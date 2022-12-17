//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class RenderPass {
    private var _subpasses: [Subpass] = []

    weak var pipeline: DevicePipeline!

    public var subpasses: [Subpass] {
        get {
            _subpasses
        }
    }

    public init(_ pipeline: DevicePipeline) {
        self.pipeline = pipeline
    }

    /// Appends a subpass to the pipeline
    /// - Parameter subpass: Subpass to append
    public func addSubpass(_ subpass: Subpass) {
        subpass.setRenderPass(self)
        _subpasses.append(subpass)
    }

    public func removeSubpass(_ subpass: Subpass) {
        _subpasses.removeAll { (v: Subpass) in
            v === subpass
        }
    }

    public func draw(_ commandBuffer: MTLCommandBuffer, _ descriptor: MTLRenderPassDescriptor, _ label: String = "") {
        var encoder = RenderCommandEncoder(commandBuffer, descriptor, label)
        for subpass in _subpasses {
            subpass.draw(&encoder)
        }
        encoder.endEncoding()
    }
}
