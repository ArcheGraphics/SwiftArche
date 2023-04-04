//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Describes how physics materials of the colliding objects are combined.
enum CombineMode: Int {
    /// Averages the friction/bounce of the two colliding materials.
    case Average = 0
    /// Uses the smaller friction/bounce of the two colliding materials.
    case Minimum = 1
    /// Multiplies the friction/bounce of the two colliding materials.
    case Multiply = 2
    /// Uses the larger friction/bounce of the two colliding materials.
    case Maximum = 3
}

/// Physics material describes how to handle colliding objects (friction, bounciness).
class PhysXPhysicsMaterial {
    internal var _pxMaterial: CPxMaterial

    init(_ staticFriction: Float,
         _ dynamicFriction: Float,
         _ bounciness: Float,
         _ frictionCombine: CombineMode,
         _ bounceCombine: CombineMode)
    {
        _pxMaterial = PhysXPhysics._pxPhysics.createMaterial(
            withStaticFriction: staticFriction,
            dynamicFriction: dynamicFriction,
            restitution: bounciness
        )

        _pxMaterial.setFrictionCombineMode(Int32(frictionCombine.rawValue))
        _pxMaterial.setRestitutionCombineMode(Int32(bounceCombine.rawValue))
    }

    func setBounciness(_ value: Float) {
        _pxMaterial.setRestitution(value)
    }

    func setDynamicFriction(_ value: Float) {
        _pxMaterial.setDynamicFriction(value)
    }

    func setStaticFriction(_ value: Float) {
        _pxMaterial.setStaticFriction(value)
    }

    func setBounceCombine(_ value: Int) {
        _pxMaterial.setRestitutionCombineMode(Int32(value))
    }

    func setFrictionCombine(_ value: Int) {
        _pxMaterial.setFrictionCombineMode(Int32(value))
    }
}
