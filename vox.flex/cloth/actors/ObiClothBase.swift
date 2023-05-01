//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiClothBase: ObiActor, IDistanceConstraintsUser, IBendConstraintsUser, IAerodynamicConstraintsUser
{
    var m_SelfCollisions = false
    var m_OneSided = false

    // distance constraints:
    var _distanceConstraintsEnabled = true
    var _stretchingScale: Float = 1
    var _stretchCompliance: Float = 0
    var _maxCompression: Float = 0

    // bend constraints:
    var _bendConstraintsEnabled = true
    var _bendCompliance: Float = 0
    var _maxBending: Float = 0.025
    var _plasticYield: Float = 0
    var _plasticCreep: Float = 0

    // aerodynamics
    var _aerodynamicsEnabled = true
    var _drag: Float = 0.05
    var _lift: Float = 0.05

    var trianglesOffset: Int = 0 /** < Offset of deformable triangles in curent solver */

    public var distanceConstraintsEnabled: Bool {
        get {
            _distanceConstraintsEnabled
        }
        set {
            _distanceConstraintsEnabled = newValue
        }
    }

    public var stretchingScale: Float {
        get {
            _stretchingScale
        }
        set {
            _stretchingScale = newValue
        }
    }

    public var stretchCompliance: Float {
        get {
            _stretchCompliance
        }
        set {
            _stretchCompliance = newValue
        }
    }

    public var maxCompression: Float {
        get {
            _maxCompression
        }
        set {
            _maxCompression = newValue
        }
    }

    public var bendConstraintsEnabled: Bool {
        get {
            _bendConstraintsEnabled
        }
        set {
            _bendConstraintsEnabled = newValue
        }
    }

    public var bendCompliance: Float {
        get {
            _bendCompliance
        }
        set {
            _bendCompliance = newValue
        }
    }

    public var maxBending: Float {
        get {
            _maxBending
        }
        set {
            _maxBending = newValue
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

    public var aerodynamicsEnabled: Bool {
        get {
            _aerodynamicsEnabled
        }
        set {
            _aerodynamicsEnabled = newValue
        }
    }

    public var drag: Float {
        get {
            _drag
        }
        set {
            _drag = newValue
        }
    }

    public var lift: Float {
        get {
            _lift
        }
        set {
            _lift = newValue
        }
    }
}
