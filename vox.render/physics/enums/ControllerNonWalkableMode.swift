//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// The up axis of the collider shape.
public enum ControllerNonWalkableMode: Int {
    /// Stops character from climbing up non-walkable slopes, but doesn't move it otherwise.
    case PreventClimbing = 0
    /// Stops character from climbing up non-walkable slopes, and forces it to slide down those slopes.
    case PreventClimbingAndForceSliding = 1
}
