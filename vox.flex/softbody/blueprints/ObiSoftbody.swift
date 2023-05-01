//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiSoftbody: ObiActor, IShapeMatchingConstraintsUser {
    var m_SoftbodyBlueprint: ObiSoftbodyBlueprintBase?

    var m_SelfCollisions = false

    private var centerBatch = -1
    private var centerShape = -1

    // shape matching constraints:
    var _shapeMatchingConstraintsEnabled = true
    var _deformationResistance: Float = 1
    var _maxDeformation: Float = 0
    var _plasticYield: Float = 0
    var _plasticCreep: Float = 0
    var _plasticRecovery: Float = 0

    public var shapeMatchingConstraintsEnabled: Bool {
        get {
            _shapeMatchingConstraintsEnabled
        }
        set {
            _shapeMatchingConstraintsEnabled = newValue
        }
    }

    public var deformationResistance: Float {
        get {
            _deformationResistance
        }
        set {
            _deformationResistance = newValue
        }
    }

    public var maxDeformation: Float {
        get {
            _maxDeformation
        }
        set {
            _maxDeformation = newValue
        }
    }

    public var plasticYield: Float {
        get {
            _plasticYield
        }
        set {
            _plasticYield = newValue
        }
    }

    public var plasticCreep: Float {
        get {
            _plasticCreep
        }
        set {
            _plasticCreep = newValue
        }
    }

    public var plasticRecovery: Float {
        get {
            _plasticRecovery
        }
        set {
            _plasticRecovery = newValue
        }
    }

    public func Teleport(position _: Vector3, rotation _: Quaternion) {}

    public func RecalculateRestShapeMatching() {}

    private func RecalculateCenterShape() {}

    public func UpdateParticleProperties() {}

    public func Interpolate() {}
}
