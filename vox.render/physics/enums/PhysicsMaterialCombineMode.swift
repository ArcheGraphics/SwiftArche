//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Describes how physics materials of the colliding objects are combined.
public enum PhysicsMaterialCombineMode: Int {
    /// Averages the friction/bounce of the two colliding materials.
    case Average
    /// Uses the smaller friction/bounce of the two colliding materials.
    case Minimum
    /// Multiplies the friction/bounce of the two colliding materials.
    case Multiply
    /// Uses the larger friction/bounce of the two colliding materials.
    case Maximum
}
