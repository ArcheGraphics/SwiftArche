//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXHingeJoint: PhysXJoint {
    private var _axisRotationQuaternion = Quaternion()
    private var _swingOffset = Vector3()
    private var _velocity = Vector3()

    init(_ collider: PhysXCollider?) {
        super.init()
        _pxJoint = PhysXPhysics._pxPhysics.createRevoluteJoint(
                nil ?? nil, SIMD3<Float>(), simd_quatf(),
                collider?._pxActor ?? nil, SIMD3<Float>(), simd_quatf()
        )
    }

    func setAxis(_ value: Vector3) {
        var value = value
        _ = value.normalize()
        let angle = acos(Vector3.dot(left: Vector3(1, 0, 0), right: value))
        let xAxis = Vector3.cross(left: Vector3(1, 0, 0), right: value)
        let axisRotationQuaternion = Quaternion.rotationAxisAngle(axis: xAxis, rad: angle)

        _setLocalPose(0, _swingOffset, axisRotationQuaternion)
    }

    func setSwingOffset(_ value: Vector3) {
        _swingOffset = value
        _setLocalPose(1, _swingOffset, _axisRotationQuaternion)
    }

    func getAngle() -> Float {
        (_pxJoint as! CPxRevoluteJoint).getAngle()
    }

    func getVelocity() -> Vector3 {
        Vector3((_pxJoint as! CPxRevoluteJoint).getVelocity())
    }

    func setHardLimit(_ lowerLimit: Float, _ upperLimit: Float, _ contactDist: Float) {
        (_pxJoint as! CPxRevoluteJoint).setLimit(CPxJointAngularLimitPair(hardLimit: lowerLimit, upperLimit, contactDist))
    }

    func setSoftLimit(_ lowerLimit: Float, _ upperLimit: Float, _ stiffness: Float, _ damping: Float) {
        (_pxJoint as! CPxRevoluteJoint).setLimit(CPxJointAngularLimitPair(softLimit: lowerLimit, upperLimit, CPxSpring(stiffness: stiffness, damping)))
    }

    func setDriveVelocity(_ velocity: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveVelocity(velocity)
    }

    func setDriveForceLimit(_ limit: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveForceLimit(limit)
    }

    func setDriveGearRatio(_ ratio: Float) {
        (_pxJoint as! CPxRevoluteJoint).setDriveGearRatio(ratio)
    }

    func setHingeJointFlag(_ flag: UInt32, _ value: Bool) {
        (_pxJoint as! CPxRevoluteJoint).setRevoluteJointFlag(CPxRevoluteJointFlag(flag), value)
    }
}
