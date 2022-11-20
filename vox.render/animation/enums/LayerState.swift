//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Layer state.
public enum LayerState {
    /// Standby state.
    case Standby
    /// Playing state.
    case Playing
    /// CrossFading state.
    case CrossFading
    /// FixedCrossFading state.
    case FixedCrossFading
}