//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXObstacle {
    internal var _pxObstacle: CPxObstacle!

    func getType() -> Int {
        Int(_pxObstacle.getType().rawValue)
    }
}

class PhysXBoxObstacle: PhysXObstacle {
    override init() {
        super.init()
        _pxObstacle = CPxBoxObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_pxObstacle as! CPxBoxObstacle).mPos = mPos.internalValue
    }

    func setRot(_ mRot: Quaternion) {
        (_pxObstacle as! CPxBoxObstacle).mRot = mRot.internalValue
    }

    func setHalfExtents(_ mHalfExtents: Vector3) {
        (_pxObstacle as! CPxBoxObstacle).mHalfExtents = mHalfExtents.internalValue
    }
}

class PhysXCapsuleObstacle: PhysXObstacle {
    override init() {
        super.init()
        _pxObstacle = CPxCapsuleObstacle()
    }

    func setPos(_ mPos: Vector3) {
        (_pxObstacle as! CPxCapsuleObstacle).mPos = mPos.internalValue
    }

    func setRot(_ mRot: Quaternion) {
        (_pxObstacle as! CPxCapsuleObstacle).mRot = mRot.internalValue
    }

    func setRadius(_ mRadius: Float) {
        (_pxObstacle as! CPxCapsuleObstacle).mRadius = mRadius
    }

    func setHalfHeight(_ mHalfHeight: Float) {
        (_pxObstacle as! CPxCapsuleObstacle).mHalfHeight = mHalfHeight
    }
}

