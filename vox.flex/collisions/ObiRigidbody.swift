//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Small helper class that lets you specify Obi-only properties for rigidbodies.
public class ObiRigidbody: ObiRigidbodyBase {
    private var unityRigidbody: DynamicCollider!
    private var prevRotation: Quaternion!
    private var prevPosition: Vector3!

    override public func onEnable() {
        unityRigidbody = entity.getComponent(DynamicCollider.self)
        prevPosition = entity.transform.worldPosition
        prevRotation = entity.transform.worldRotationQuaternion
    }

    private func UpdateKinematicVelocities(stepTime _: Float) {}

    override public func UpdateIfNeeded(stepTime _: Float) {}

    override public func UpdateVelocities(linearDelta _: Vector3, angularDelta _: Vector3) {}
}
