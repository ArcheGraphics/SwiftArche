//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class PhysXJoint {
    internal var _pxJoint: CPxJoint!

    func setActors(_ actor0: PhysXCollider?, _ actor1: PhysXCollider?) {
        _pxJoint.setActors(actor0?._pxActor, actor1?._pxActor)
    }

    func setLocalPose(_ actor: Int, _ position: Vector3, _ rotation: Quaternion) {
        _pxJoint.setLocalPose(CPxJointActorIndex(UInt32(actor)), position.internalValue, rotation: rotation.internalValue)
    }

    func setBreakForce(_ force: Float, _ torque: Float) {
        _pxJoint.setBreakForce(force, torque)
    }

    func setConstraintFlag(_ flags: Int, _ value: Bool) {
        _pxJoint.setConstraintFlag(CPxConstraintFlag(UInt32(flags)), value)
    }

    func setInvMassScale0(_ invMassScale: Float) {
        _pxJoint.setInvMassScale0(invMassScale)
    }

    func setInvInertiaScale0(_ invInertiaScale: Float) {
        _pxJoint.setInvInertiaScale0(invInertiaScale)
    }

    func setInvMassScale1(_ invMassScale: Float) {
        _pxJoint.setInvMassScale1(invMassScale)
    }

    func setInvInertiaScale1(_ invInertiaScale: Float) {
        _pxJoint.setInvInertiaScale1(invInertiaScale)
    }
}
