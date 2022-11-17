//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXCapsuleCharacterController: PhysXCharacterController {
    func setRadius(_ radius: Float) -> Bool {
        (_pxController as! CPxCapsuleController).setRadius(radius)
    }

    func setHeight(_ height: Float) -> Bool {
        (_pxController as! CPxCapsuleController).setHeight(height)
    }

    func setClimbingMode(_ mode: Int) -> Bool {
        (_pxController as! CPxCapsuleController).setClimbingMode(CPxCapsuleClimbingMode(UInt32(mode)))
    }
}
