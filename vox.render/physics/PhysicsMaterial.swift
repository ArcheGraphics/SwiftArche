//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Material class to represent a set of surface properties.
public class PhysicsMaterial: Serializable {
    private var _bounciness: Float = 0.1
    private var _dynamicFriction: Float = 0.1
    private var _staticFriction: Float = 0.1
    private var _bounceCombine: PhysicsMaterialCombineMode = PhysicsMaterialCombineMode.Average
    private var _frictionCombine: PhysicsMaterialCombineMode = PhysicsMaterialCombineMode.Average

    internal var _nativeMaterial: PhysXPhysicsMaterial

    public required init() {
        _nativeMaterial = PhysXPhysics.createPhysicsMaterial(
                _staticFriction,
                _dynamicFriction,
                _bounciness,
                _bounceCombine.rawValue,
                _frictionCombine.rawValue
        )
    }

    /// The coefficient of bounciness.
    public var bounciness: Float {
        get {
            _bounciness
        }
        set {
            _bounciness = newValue
            _nativeMaterial.setBounciness(newValue)
        }
    }

    /// The DynamicFriction value.
    public var dynamicFriction: Float {
        get {
            _dynamicFriction
        }
        set {
            _dynamicFriction = newValue
            _nativeMaterial.setDynamicFriction(newValue)
        }
    }

    /// The coefficient of static friction.
    public var staticFriction: Float {
        get {
            _staticFriction
        }
        set {
            _staticFriction = newValue
            _nativeMaterial.setStaticFriction(newValue)
        }
    }

    /// The restitution combine mode.
    public var bounceCombine: PhysicsMaterialCombineMode {
        get {
            _bounceCombine
        }
        set {
            _bounceCombine = newValue
            _nativeMaterial.setBounceCombine(newValue.rawValue)
        }
    }

    /// The friction combine mode.
    public var frictionCombine: PhysicsMaterialCombineMode {
        get {
            _frictionCombine
        }
        set {
            _frictionCombine = newValue
            _nativeMaterial.setFrictionCombine(newValue.rawValue)
        }
    }
}
