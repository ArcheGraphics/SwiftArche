//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// A fixed joint permits no relative movement between two colliders. ie the colliders are glued together.
public class FixedJoint: Joint {
    override func _onAwake() {
        _collider.collider = entity.getComponent(Collider.self)
        _nativeJoint = PhysXPhysics.createFixedJoint(_collider.collider!._nativeCollider)
        _nativeJoint.setName(name)
    }
}
