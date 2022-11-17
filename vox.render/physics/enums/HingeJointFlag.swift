//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Flags specific to the Hinge Joint.
enum HingeJointFlag: UInt32 {
    /// enable the limit
    case  LimitEnabled = 1
    /// enable the drive
    case  DriveEnabled = 2
    /// if the existing velocity is beyond the drive velocity, do not add force
    case  DriveFreeSpin = 4
}