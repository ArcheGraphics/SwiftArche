//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class RenderPass {
    private var _descriptor: MTLRenderPassDescriptor
    private var _subpasses: [Subpass] = []

    weak var pipeline: DevicePipeline!

    var subpasses: [Subpass] {
        get {
            _subpasses
        }
    }

    var descriptor: MTLRenderPassDescriptor {
        get {
            _descriptor
        }
    }

    init(_ descriptor: MTLRenderPassDescriptor, _ pipeline: DevicePipeline) {
        _descriptor = descriptor
        self.pipeline = pipeline
    }

    /// Appends a subpass to the pipeline
    /// - Parameter subpass: Subpass to append
    func addSubpass(_ subpass: Subpass) {
        subpass.setRenderPass(self)
        _subpasses.append(subpass)
    }

    func draw(commandBuffer: MTLCommandBuffer, label: String = "") {
        assert(_subpasses.count > 0)
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: _descriptor) else {
            return
        }
        encoder.label = label

        for subpass in _subpasses {
            subpass.draw(encoder)
        }
        encoder.endEncoding()
    }
}