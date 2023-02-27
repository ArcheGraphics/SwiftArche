//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This abstract class is the base for all other controller components (such as 'AdvancedWalkerController');
/// It can be extended to create a custom controller class;
public protocol Controller {
    //Getters;
    func GetVelocity() -> Vector3
    func GetMovementVelocity() -> Vector3
    func IsGrounded() -> Bool

    //Events;
    var OnJump: ((Vector3)->Void)? {get set}
    var OnLand: ((Vector3)->Void)? {get set}
}
