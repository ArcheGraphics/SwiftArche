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
    case Depth
    /// Depth only alpha-masked geometry.
    case DepthAlphaMasked
    /// G-buffer fill opaque geometry.
    case GBuffer
    /// G-buffer fill alpha-masked geometry.
    case GBufferAlphaMasked
    /// Forward render opaque geometry.
    case Forward
    /// Forward render alpha-masked geometry.
    case ForwardAlphaMasked
    /// Forward render transparent geometry.
    case ForwardTransparent

    case Count
};
