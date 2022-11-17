//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXSphericalJoint: PhysXJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createSphericalJoint(
                actor0?._pxActor ?? nil, position0.internalValue, rotation0.internalValue,
                actor1?._pxActor ?? nil, position1.internalValue, rotation1.internalValue)
    }

    func setHardLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_pxJoint as! CPxSphericalJoint).setLimitCone(CPxJointLimitCone(hardLimit: yLimitAngle, zLimitAngle, contactDist))
    }

    func setSoftLimitCone(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxSphericalJoint).setLimitCone(
                CPxJointLimitCone(softLimit: yLimitAngle, zLimitAngle,
                        CPxSpring(stiffness: stiffness, damping)))
    }

    func setSphericalJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxSphericalJoint).setSphericalJointFlag(CPxSphericalJointFlag(UInt32(flag)), value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxSphericalJoint).setProjectionLinearTolerance(tolerance)
    }
}
