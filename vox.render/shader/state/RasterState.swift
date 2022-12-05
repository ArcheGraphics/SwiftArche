//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Raster state.
public class RasterState {
    /// Specifies whether or not front- and/or back-facing polygons can be culled.
    public var cullMode: MTLCullMode = .front
    /// A constant bias applied to all fragments.
    public var depthBias: Float = 0
    /// A bias that scales with the depth gradient of the primitive.
    public var depthSlopeScale: Float = 1.0
    /// The maximum bias value to apply to the fragment.
    public var depthClamp: Float = 0.01

    func _apply(_ frontFaceInvert: Bool,
                _ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setCullMode(cullMode)

        if frontFaceInvert {
            renderEncoder.setFrontFacing(.counterClockwise)
        } else {
            renderEncoder.setFrontFacing(.clockwise)
        }

        if (depthBias != 0 || depthSlopeScale != 0 || depthClamp != 0) {
            renderEncoder.setDepthBias(depthBias, slopeScale: depthSlopeScale, clamp: depthClamp)
        }
    }
}
