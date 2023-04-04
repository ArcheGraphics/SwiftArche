//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Material class to represent a set of surface properties.
public class PhysicsMaterial: Serializable {
    internal var _nativeMaterial: PhysXPhysicsMaterial!

    public required init() {
        _nativeMaterial = PhysXPhysics.createPhysicsMaterial(
            staticFriction,
            dynamicFriction,
            bounciness,
            bounceCombine.rawValue,
            frictionCombine.rawValue
        )
    }

    /// The coefficient of bounciness.
    @Serialized(default: 0.1)
    public var bounciness: Float {
        didSet {
            _nativeMaterial.setBounciness(bounciness)
        }
    }

    /// The DynamicFriction value.
    @Serialized(default: 0.1)
    public var dynamicFriction: Float {
        didSet {
            _nativeMaterial.setDynamicFriction(dynamicFriction)
        }
    }

    /// The coefficient of static friction.
    @Serialized(default: 0.1)
    public var staticFriction: Float {
        didSet {
            _nativeMaterial.setStaticFriction(staticFriction)
        }
    }

    /// The restitution combine mode.
    @Serialized(default: .Average)
    public var bounceCombine: PhysicsMaterialCombineMode {
        didSet {
            _nativeMaterial.setBounceCombine(bounceCombine.rawValue)
        }
    }

    /// The friction combine mode.
    @Serialized(default: .Average)
    public var frictionCombine: PhysicsMaterialCombineMode {
        didSet {
            _nativeMaterial.setFrictionCombine(frictionCombine.rawValue)
        }
    }
}
