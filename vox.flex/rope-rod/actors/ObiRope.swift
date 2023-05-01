//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRope: ObiRopeBase, IDistanceConstraintsUser, IBendConstraintsUser {
    var m_RopeBlueprint: ObiRopeBlueprint?
    private var m_RopeBlueprintInstance: ObiRopeBlueprint?

    // rope has a list of structural elements.
    // each structural element is equivalent to 1 distance constraint and 2 bend constraints (with previous, and following element).
    // a structural element has force and rest length.
    // a function re-generates constraints from structural elements when needed, placing them in the appropiate batches.

    public var tearingEnabled = false
    /// Factor that controls how much a structural cloth spring can stretch before breaking
    public var tearResistanceMultiplier: Float = 1000
    public var tearRate = 1

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

    var tornElements: [ObiStructuralElement] = []

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
}
