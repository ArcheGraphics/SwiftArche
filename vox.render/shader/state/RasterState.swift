//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Raster state.
public class RasterState {
    /// Specifies whether or not front- and/or back-facing polygons can be culled.
    public var cullMode: MTLCullMode = .back
    public var fillingMode: MTLTriangleFillMode = .fill

    func _apply(_ frontFaceInvert: Bool,
                _ renderEncoder: MTLRenderCommandEncoder)
    {
        renderEncoder.setCullMode(cullMode)
        renderEncoder.setTriangleFillMode(fillingMode)
        if frontFaceInvert {
            renderEncoder.setFrontFacing(.clockwise)
        } else {
            renderEncoder.setFrontFacing(.counterClockwise)
        }
    }
}
