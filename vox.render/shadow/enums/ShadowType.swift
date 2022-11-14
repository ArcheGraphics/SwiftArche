//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Determines which type of shadows should be used.
public enum ShadowType : Int {
    /// Disable Shadows.
    case None = 0
    /// Hard Shadows Only.
    case Hard = 1
    /// Cast "soft" shadows with low range.
    case SoftLow = 2
    /// Cast "soft" shadows with large range.
    case SoftHigh = 3
}
