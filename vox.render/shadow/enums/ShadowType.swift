//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Determines which type of shadows should be used.
public  enum ShadowType {
    /// Disable Shadows.
    case None
    /// Hard Shadows Only.
    case Hard
    /// Cast "soft" shadows with low range.
    case SoftLow
    /// Cast "soft" shadows with large range.
    case SoftHigh
}
