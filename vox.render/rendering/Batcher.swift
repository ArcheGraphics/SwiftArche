//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public protocol Batcher {
    func drawBatcher(_ encoder: inout RenderCommandEncoder, _ camera: Camera)

    func flush()
}
