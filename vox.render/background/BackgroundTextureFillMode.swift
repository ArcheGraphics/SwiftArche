//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Filling mode of background texture.
public enum BackgroundTextureFillMode {
    /// Maintain the aspect ratio and scale the texture to fit the width of the canvas.
    case AspectFitWidth
    /// Maintain the aspect ratio and scale the texture to fit the height of the canvas.
    case AspectFitHeight
    /// Scale the texture fully fills the canvas. */
    case Fill
}
