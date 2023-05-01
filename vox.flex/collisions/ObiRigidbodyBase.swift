//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Small helper class that lets you specify Obi-only properties for rigidbodies.
public class ObiRigidbodyBase: Script {
    public var kinematicForParticles = false

    override public func onEnable() {}

    override public func onDisable() {}

    public func UpdateIfNeeded(stepTime _: Float) {}

    public func UpdateVelocities(linearDelta _: Vector3, angularDelta _: Vector3) {}
}
