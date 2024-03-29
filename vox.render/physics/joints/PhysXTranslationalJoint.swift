//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class PhysXTranslationalJoint: PhysXJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion)
    {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createPrismaticJoint(
            actor0?._pxActor ?? nil, position0.internalValue, rotation0.internalValue,
            actor1?._pxActor ?? nil, position1.internalValue, rotation1.internalValue
        )
    }

    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxPrismaticJoint).setLimit(CPxJointLinearLimitPair(
            hardLimit: CPxTolerancesScale.new(), lowerLimit, upperLimit, contactDist
        ))
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxPrismaticJoint).setLimit(
            CPxJointLinearLimitPair(softLimit: lowerLimit, upperLimit,
                                    CPxSpring(stiffness: stiffness, damping)))
    }

    func setPrismaticJointFlag(_ flag: Int, _ value: Bool) {
        (_pxJoint as! CPxPrismaticJoint).setPrismaticJointFlag(CPxPrismaticJointFlag(UInt32(flag)), value)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxPrismaticJoint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxPrismaticJoint).setProjectionAngularTolerance(tolerance)
    }
}
