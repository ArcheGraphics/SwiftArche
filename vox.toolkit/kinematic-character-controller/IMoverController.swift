//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public protocol IMoverController {
    /// This is called to let you tell the PhysicsMover where it should be right now
    func UpdateMovement(goalPosition: inout Vector3, goalRotation: inout Quaternion, deltaTime: Float)
}
