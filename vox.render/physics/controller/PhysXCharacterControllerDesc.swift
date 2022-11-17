//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXCharacterControllerDesc {
    internal var _pxControllerDesc: CPxControllerDesc!

    func getType() -> Int {
        Int(_pxControllerDesc.getType().rawValue)
    }
}
