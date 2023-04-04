//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class PhysXConfigurableJoint: PhysXJoint {
    init(_ actor0: PhysXCollider?, _ position0: Vector3, _ rotation0: Quaternion,
         _ actor1: PhysXCollider?, _ position1: Vector3, _ rotation1: Quaternion)
    {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createD6Joint(
            actor0?._pxActor ?? nil, position0.internalValue, rotation0.internalValue,
            actor1?._pxActor ?? nil, position1.internalValue, rotation1.internalValue
        )
    }

    func setMotion(_ axis: Int, _ type: Int) {
        (_pxJoint as! CPxD6Joint).setMotion(CPxD6Axis(UInt32(axis)), CPxD6Motion(UInt32(type)))
    }

    func setHardDistanceLimit(_ extent: Float, contactDist: Float) {
        (_pxJoint as! CPxD6Joint).setDistanceLimit(CPxJointLinearLimit(hardLimit: CPxTolerancesScale.new(), extent, contactDist))
    }

    func setSoftDistanceLimit(_ extent: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxD6Joint).setDistanceLimit(CPxJointLinearLimit(softLimit: extent,
                                                                       CPxSpring(stiffness: stiffness, damping)))
    }

    func setHardLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxD6Joint).setLinearLimit(CPxD6Axis(UInt32(axis)),
                                                 CPxJointLinearLimitPair(hardLimit: CPxTolerancesScale.new(),
                                                                         lowerLimit, upperLimit, contactDist))
    }

    func setSoftLinearLimit(_ axis: Int, _ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxD6Joint).setLinearLimit(CPxD6Axis(UInt32(axis)),
                                                 CPxJointLinearLimitPair(softLimit: lowerLimit, upperLimit,
                                                                         CPxSpring(stiffness: stiffness, damping)))
    }

    func setHardTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxD6Joint).setTwistLimit(CPxJointAngularLimitPair(hardLimit: lowerLimit, upperLimit, contactDist))
    }

    func setSoftTwistLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxD6Joint).setTwistLimit(CPxJointAngularLimitPair(softLimit: lowerLimit, upperLimit,
                                                                         CPxSpring(stiffness: stiffness, damping)))
    }

    func setHardSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ contactDist: Float) {
        (_pxJoint as! CPxD6Joint).setSwingLimit(CPxJointLimitCone(hardLimit: yLimitAngle, zLimitAngle, contactDist))
    }

    func setSoftSwingLimit(_ yLimitAngle: Float, _ zLimitAngle: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxD6Joint).setSwingLimit(CPxJointLimitCone(softLimit: yLimitAngle, zLimitAngle,
                                                                  CPxSpring(stiffness: stiffness, damping)))
    }

    func setHardPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ contactDist: Float)
    {
        (_pxJoint as! CPxD6Joint).setPyramidSwingLimit(CPxJointLimitPyramid(hardLimit: yLimitAngleMin, yLimitAngleMax,
                                                                            zLimitAngleMin, zLimitAngleMax, contactDist))
    }

    func setSoftPyramidSwingLimit(_ yLimitAngleMin: Float, _ yLimitAngleMax: Float,
                                  _ zLimitAngleMin: Float, _ zLimitAngleMax: Float, _ stiffness: Float, _ damping: Float)
    {
        (_pxJoint as! CPxD6Joint).setPyramidSwingLimit(CPxJointLimitPyramid(softLimit: yLimitAngleMin, yLimitAngleMax,
                                                                            zLimitAngleMin, zLimitAngleMax, CPxSpring(stiffness: stiffness, damping)))
    }

    func setDrive(_ index: Int, _ driveStiffness: Float, _ driveDamping: Float, _ driveForceLimit: Float) {
        (_pxJoint as! CPxD6Joint).setDrive(CPxD6Drive(UInt32(index)),
                                           CPxD6JointDrive(limitStiffness: driveStiffness, driveDamping, driveForceLimit))
    }

    func setDrivePosition(_ position: Vector3, _ rotation: Quaternion) {
        (_pxJoint as! CPxD6Joint).setDrivePosition(position.internalValue, rotation: rotation.internalValue)
    }

    func setDriveVelocity(_ linear: Vector3, _ angular: Vector3) {
        (_pxJoint as! CPxD6Joint).setDriveVelocity(linear.internalValue, angular.internalValue)
    }

    func setProjectionLinearTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxD6Joint).setProjectionLinearTolerance(tolerance)
    }

    func setProjectionAngularTolerance(_ tolerance: Float) {
        (_pxJoint as! CPxD6Joint).setProjectionAngularTolerance(tolerance)
    }
}
