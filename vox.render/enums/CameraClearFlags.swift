//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Camera clear flags enumeration.
public enum CameraClearFlags: Int {
    /// Do nothing.
    case None = 0x0
    /// Clear color with scene background.
    case Color = 0x1
    /// Clear depth only.
    case Depth = 0x2
    /// Clear depth only.
    case Stencil = 0x4

    /// Clear color with scene background and depth.
    case ColorDepth = 0x3
    /// Clear color with scene background and stencil.
    case ColorStencil = 0x5
    /// Clear depth and stencil. */
    case DepthStencil = 0x6

    /// Clear color with scene background, depth, and stencil.
    case All = 0x7
}
