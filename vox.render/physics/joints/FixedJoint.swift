//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A fixed joint permits no relative movement between two colliders. ie the colliders are glued together.
public class FixedJoint: Joint {
    override func _onAwake() {
        _collider.collider = entity.getComponent(Collider.self)
        _nativeJoint = PhysXPhysics.createFixedJoint(_collider.collider!._nativeCollider)
        _nativeJoint.setName(name)
    }
    
    required init(_ engine: Engine) {
        super.init(engine)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
    }
}
