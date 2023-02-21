//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The up axis of the collider shape.
public enum ControllerCollisionFlag: UInt8 {
    /// Character is colliding to the sides.
    case Sides = 1
    /// Character has collision above.
    case Up = 2
    /// Character has collision below.
    case Down = 4
}
