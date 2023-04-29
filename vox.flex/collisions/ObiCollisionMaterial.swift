//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

// Holds information about the physics properties of a particle or collider, and how it should react to collisions.
public class ObiCollisionMaterial: Script {
    public var dynamicFriction: Float = 0.1
    public var staticFriction: Float = 0
    public var stickiness: Float = 0.02
    public var stickDistance: Float = 0.01

    public var frictionCombine: Oni.MaterialCombineMode = .Maximum
    public var stickinessCombine: Oni.MaterialCombineMode = .Maximum

    public var rollingContacts = false

    public var rollingFriction: Float = 0
}
