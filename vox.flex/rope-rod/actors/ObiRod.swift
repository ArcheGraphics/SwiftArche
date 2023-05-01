//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiRod: ObiRopeBase, IStretchShearConstraintsUser, IBendTwistConstraintsUser, IChainConstraintsUser
{
    var m_RodBlueprint: ObiRodBlueprint?

    // distance constraints:
    var _stretchShearConstraintsEnabled = true
    var _stretchCompliance: Float = 0
    var _shear1Compliance: Float = 0
    var _shear2Compliance: Float = 0

    // bend constraints:
    var _bendTwistConstraintsEnabled = true
    var _torsionCompliance: Float = 0
    var _bend1Compliance: Float = 0
    var _bend2Compliance: Float = 0
    var _plasticYield: Float = 0
    var _plasticCreep: Float = 0

    // chain constraints:
    var _chainConstraintsEnabled = true
    var _tightness: Float = 1

    public var stretchShearConstraintsEnabled: Bool {
        get { _stretchShearConstraintsEnabled }
        set {
            _stretchShearConstraintsEnabled = newValue
        }
    }

    public func GetStretchShearCompliance(batch _: ObiStretchShearConstraintsBatch, constraintIndex _: Int) -> Vector3 {
        Vector3()
    }

    public var bendTwistConstraintsEnabled: Bool {
        get {
            _bendTwistConstraintsEnabled
        }
        set {
            _bendTwistConstraintsEnabled = newValue
        }
    }

    public func GetBendTwistCompliance(batch _: ObiBendTwistConstraintsBatch, constraintIndex _: Int) -> Vector3 {
        Vector3()
    }

    public func GetBendTwistPlasticity(batch _: ObiBendTwistConstraintsBatch, constraintIndex _: Int) -> Vector2 {
        Vector2()
    }

    public var chainConstraintsEnabled: Bool {
        get {
            _chainConstraintsEnabled
        }
        set {
            _chainConstraintsEnabled = newValue
        }
    }

    public var tightness: Float {
        get {
            _tightness
        }
        set {
            _tightness = newValue
        }
    }
}
