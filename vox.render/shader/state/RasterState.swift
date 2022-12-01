//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Raster state.
public class RasterState {
    /// Specifies whether or not front- and/or back-facing polygons can be culled. */
    public var cullMode: MTLCullMode = .front
    /// The multiplier by which an implementation-specific value is multiplied with to create a constant depth offset. */
    public var depthBias: Float = 0
    /// The scale factor for the variable depth offset for each polygon. */
    public var slopeScaledDepthBias: Float = 0

    func _apply(_ frontFaceInvert: Bool,
                _ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setCullMode(cullMode)

        if frontFaceInvert {
            renderEncoder.setFrontFacing(.counterClockwise)
        } else {
            renderEncoder.setFrontFacing(.clockwise)
        }

        // apply polygonOffset.
        if (depthBias != 0 || slopeScaledDepthBias != 0) {
            renderEncoder.setDepthBias(depthBias, slopeScale: slopeScaledDepthBias, clamp: 0)
        }
    }
}
