//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class PhysXJoint {
    var _pxJoint: CPxJoint!
    var _collider: PhysXCollider?
    private var _connectedAnchor = Vector3()
    private var _breakForce: Float = .greatestFiniteMagnitude
    private var _breakTorque: Float = .greatestFiniteMagnitude

    func setConnectedCollider(_ value: PhysXCollider?) {
        _pxJoint.setActors(value?._pxActor, _collider?._pxActor)
    }

    func setConnectedAnchor(_ value: Vector3) {
        _connectedAnchor = value
        _setLocalPose(0, value, Quaternion())
    }

    func setConnectedMassScale(_ value: Float) {
        _pxJoint.setInvMassScale0(1 / value)
    }

    func setConnectedInertiaScale(_ value: Float) {
        _pxJoint.setInvInertiaScale0(1 / value)
    }

    func setMassScale(_ value: Float) {
        _pxJoint.setInvMassScale1(1 / value)
    }

    func setInertiaScale(_ value: Float) {
        _pxJoint.setInvInertiaScale1(1 / value)
    }

    func setBreakForce(_ value: Float) {
        _breakForce = value
        _pxJoint.setBreakForce(_breakForce, _breakTorque)
    }

    func setBreakTorque(_ value: Float) {
        _breakTorque = value
        _pxJoint.setBreakForce(_breakForce, _breakTorque)
    }

    func setName(_ name: String) {
        _pxJoint.setName(name)
    }

    /// Set the joint local pose for an actor.
    /// - Parameters:
    ///   - actor: 0 for the first actor, 1 for the second actor.
    ///   - position: the local position for the actor this joint
    ///   - rotation: the local rotation for the actor this joint
    func _setLocalPose(_ actor: UInt32, _ position: Vector3, _ rotation: Quaternion) {
        _pxJoint.setLocalPose(CPxJointActorIndex(actor), position.internalValue, rotation: rotation.internalValue)
    }
}
