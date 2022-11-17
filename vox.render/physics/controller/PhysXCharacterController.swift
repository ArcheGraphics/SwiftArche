//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXCharacterController {
    internal var _id: Int!
    internal var _pxController: CPxController!

    func move(_ disp: Vector3, _ minDist: Float, _ elapsedTime: Float) -> UInt8 {
        _pxController.move(disp.internalValue, minDist, elapsedTime)
    }

    func isSetControllerCollisionFlag(_ flags: UInt8, _ flag: Int) -> Bool {
        _pxController.isSetControllerCollisionFlag(flags, CPxControllerCollisionFlag(UInt32(flag)))
    }

    func setPosition(_ position: Vector3) -> Bool {
        _pxController.setPosition(position.internalValue)
    }

    func setFootPosition(_ position: Vector3) {
        _pxController.setFootPosition(position.internalValue)
    }

    func setStepOffset(_ offset: Float) {
        _pxController.setStepOffset(offset)
    }

    func setNonWalkableMode(_ flag: Int) {
        _pxController.setNonWalkableMode(CPxControllerNonWalkableMode(UInt32(flag)))
    }

    func setContactOffset(_ offset: Float) {
        _pxController.setContactOffset(offset)
    }

    func setUpDirection(_ up: Vector3) {
        _pxController.setUpDirection(up.internalValue)
    }

    func setSlopeLimit(_ slopeLimit: Float) {
        _pxController.setSlopeLimit(slopeLimit)
    }

    func invalidateCache() {
        _pxController.invalidateCache()
    }

    func resize(_ height: Float) {
        _pxController.resize(height)
    }

    func setUniqueID(_ id: Int) {
        _id = id
        _pxController.setQueryFilterData(UInt32(id), w1: 0, w2: 0, w3: 0)
    }

    func getPosition() -> Vector3 {
        Vector3(_pxController.getPosition())
    }
}
