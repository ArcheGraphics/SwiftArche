//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXBoxCharacterController: PhysXCharacterController {
    func setHalfHeight(_ halfHeight: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfHeight(halfHeight)
    }

    func setHalfSideExtent(_ halfSideExtent: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfSideExtent(halfSideExtent)
    }

    func setHalfForwardExtent(_ halfForwardExtent: Float) -> Bool {
        (_pxController as! CPxBoxController).setHalfForwardExtent(halfForwardExtent)
    }
}
