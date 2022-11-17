//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXFixedJoint: PhysXJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createFixedJoint(
                actor0?._pxActor ?? nil, position0.internalValue, rotation0.internalValue,
                actor1?._pxActor ?? nil, position1.internalValue, rotation1.internalValue)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxFixedJoint).setProjectionAngularTolerance(tolerance)
    }
}
