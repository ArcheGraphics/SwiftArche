//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Enumerates the range of supported render pass types.
///  These passes need to be handled by renderer implementations.
enum XRenderPass {
    /// Depth only opaque geometry.
    case RenderPassDepth
    /// Depth only alpha-masked geometry.
    case RenderPassDepthAlphaMasked
    /// G-buffer fill opaque geometry.
    case RenderPassGBuffer
    /// G-buffer fill alpha-masked geometry.
    case RenderPassGBufferAlphaMasked
    /// Forward render opaque geometry.
    case RenderPassForward
    /// Forward render alpha-masked geometry.
    case RenderPassForwardAlphaMasked
    /// Forward render transparent geometry.
    case RenderPassForwardTransparent

    case RenderPassCount
};
