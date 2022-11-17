//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// JointLimits is used to limit the joints angle.
public struct JointLimits {
    /// The upper angular limit (in degrees) of the joint. */
    var max: Float = 0
    /// The lower angular limit (in degrees) of the joint. */
    var min: Float = 0
    /// Distance inside the limit value at which the limit will be considered to be active by the solver. */
    var contactDistance: Float = -1

    /// The spring forces used to reach the target position. */
    var stiffness: Float = 0
    /// The damper force uses to dampen the spring. */
    var damping: Float = 0
}
