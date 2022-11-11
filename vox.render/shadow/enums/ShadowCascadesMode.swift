//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Number of cascades to use for directional light shadows.
enum ShadowCascadesMode: Int {
    /// No cascades
    case NoCascades = 1
    /// Two cascades
    case TwoCascades = 2
    /// Four cascades
    case FourCascades = 4
}