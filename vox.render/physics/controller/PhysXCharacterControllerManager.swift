//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXCharacterControllerManager {
    internal var _pxControllerManager: CPxControllerManager!

    func purgeControllers() {
        _pxControllerManager.purgeControllers()
    }

    func createController(_ desc: PhysXCharacterControllerDesc) -> PhysXCharacterController {
        let pxController = _pxControllerManager.createController((desc as! PhysXCharacterControllerDesc)._pxControllerDesc)
        if desc.getType() == CPxControllerShapeType_eCAPSULE.rawValue {
            let controller = PhysXCapsuleCharacterController()
            controller._pxController = pxController
            return controller
        } else {
            let controller = PhysXBoxCharacterController()
            controller._pxController = pxController
            return controller
        }
    }

    func computeInteractions(_ elapsedTime: Float) {
        _pxControllerManager.computeInteractions(elapsedTime)
    }

    func setTessellation(_ flag: Bool, _ maxEdgeLength: Float) {
        _pxControllerManager.setTessellation(flag, maxEdgeLength)
    }

    func setOverlapRecoveryModule(_ flag: Bool) {
        _pxControllerManager.setOverlapRecoveryModule(flag)
    }

    func setPreciseSweeps(_ flag: Bool) {
        _pxControllerManager.setPreciseSweeps(flag)
    }

    func setPreventVerticalSlidingAgainstCeiling(_ flag: Bool) {
        _pxControllerManager.setPreventVerticalSlidingAgainstCeiling(flag)
    }

    func shiftOrigin(_ shift: Vector3) {
        _pxControllerManager.shiftOrigin(shift.internalValue)
    }
}
