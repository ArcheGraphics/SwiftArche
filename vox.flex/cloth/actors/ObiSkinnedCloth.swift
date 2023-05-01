//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiSkinnedCloth: ObiClothBase, ITetherConstraintsUser, ISkinConstraintsUser {
    var m_SkinnedClothBlueprint: ObiSkinnedClothBlueprint?

    // tethers
    var _tetherConstraintsEnabled = true
    var _tetherCompliance: Float = 0
    var _tetherScale: Float = 1

    public var tetherConstraintsEnabled: Bool {
        get {
            _tetherConstraintsEnabled
        }
        set {
            _tetherConstraintsEnabled = newValue
        }
    }

    public var tetherCompliance: Float {
        get {
            _tetherCompliance
        }
        set {
            _tetherCompliance = newValue
        }
    }

    public var tetherScale: Float {
        get {
            _tetherScale
        }
        set {
            _tetherScale = newValue
        }
    }

    public var skinConstraintsEnabled: Bool {
        get {
            true
        }
        set {}
    }

    public func GetSkinRadiiBackstop(batch _: ObiSkinConstraintsBatch, constraintIndex _: Int) -> Vector3 {
        Vector3()
    }

    public func GetSkinCompliance(batch _: ObiSkinConstraintsBatch, constraintIndex _: Int) -> Float {
        0
    }
}
