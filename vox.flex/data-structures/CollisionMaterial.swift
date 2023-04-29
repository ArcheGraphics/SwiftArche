//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct CollisionMaterial {
    public var dynamicFriction: Float
    public var staticFriction: Float
    public var rollingFriction: Float
    public var stickiness: Float
    public var stickDistance: Float
    public var frictionCombine: Oni.MaterialCombineMode
    public var stickinessCombine: Oni.MaterialCombineMode
    public var rollingContacts: Int

    public mutating func FromObiCollisionMaterial(material: ObiCollisionMaterial) {
        dynamicFriction = material.dynamicFriction
        staticFriction = material.staticFriction
        stickiness = material.stickiness
        stickDistance = material.stickDistance
        rollingFriction = material.rollingFriction
        frictionCombine = material.frictionCombine
        stickinessCombine = material.stickinessCombine
        rollingContacts = material.rollingContacts ? 1 : 0
    }
}
