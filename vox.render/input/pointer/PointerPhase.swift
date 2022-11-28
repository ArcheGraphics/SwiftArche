//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The current phase of the pointer.
public enum PointerPhase {
    /// A Pointer pressed on the screen.
    case Down
    /// A pointer moved on the screen.
    case Move
    /// A Pointer pressed on the screen but hasn't moved.
    case Stationary
    /// A pointer was lifted from the screen.
    case Up
    /// The system cancelled tracking for the pointer.
    case Leave
}
