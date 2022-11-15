//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class Subpass {
    weak var _renderPass: RenderPass!

    func setRenderPass(_ renderPass: RenderPass) {
        _renderPass = renderPass
    }

    func draw(_ encoder: MTLRenderCommandEncoder) {}
}