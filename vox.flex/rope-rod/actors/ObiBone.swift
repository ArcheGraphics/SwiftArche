//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiBone: ObiActor, IStretchShearConstraintsUser, IBendTwistConstraintsUser, ISkinConstraintsUser
{
    public class BonePropertyCurve {
        public var multiplier: Float
        //          public var curve: AnimationCurve

        public init(multiplier: Float, curveValue _: Float) {
            self.multiplier = multiplier
            //              this.curve = new AnimationCurve(new Keyframe(0, curveValue), new Keyframe(1, curveValue));
        }

        public func Evaluate(time _: Float) -> Float {
            0
            //              return curve.Evaluate(time) * multiplier;
        }
    }

    public class IgnoredBone {
        public var bone: Transform?
        public var ignoreChildren: Bool = false
    }

    var m_BoneBlueprint: ObiBoneBlueprint?

    var m_SelfCollisions = false

    var _radius = BonePropertyCurve(multiplier: 0.1, curveValue: 1)
    var _mass = BonePropertyCurve(multiplier: 0.1, curveValue: 1)
    var _rotationalMass = BonePropertyCurve(multiplier: 0.1, curveValue: 1)

    // skin constraints:
    var _skinConstraintsEnabled = true
    var _skinCompliance = BonePropertyCurve(multiplier: 0.01, curveValue: 1)
    var _skinRadius = BonePropertyCurve(multiplier: 0.1, curveValue: 1)

    // distance constraints:
    var _stretchShearConstraintsEnabled = true
    var _stretchCompliance = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _shear1Compliance = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _shear2Compliance = BonePropertyCurve(multiplier: 0, curveValue: 1)

    // bend constraints:
    var _bendTwistConstraintsEnabled = true
    var _torsionCompliance = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _bend1Compliance = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _bend2Compliance = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _plasticYield = BonePropertyCurve(multiplier: 0, curveValue: 1)
    var _plasticCreep = BonePropertyCurve(multiplier: 0, curveValue: 1)

    /// Filter used for collision detection.
    private let filter = ObiUtils.MakeFilter(mask: ObiUtils.CollideWithEverything, category: 1)

    public var fixRoot = true
    public var stretchBones = true
    public var ignored: [IgnoredBone] = []

    public var stretchShearConstraintsEnabled: Bool {
        get {
            _stretchShearConstraintsEnabled
        }
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

    public var skinConstraintsEnabled: Bool {
        get {
            _skinConstraintsEnabled
        }
        set {
            _skinConstraintsEnabled = newValue
        }
    }

    public func GetSkinRadiiBackstop(batch _: ObiSkinConstraintsBatch, constraintIndex _: Int) -> Vector3 {
        Vector3()
    }

    public func GetSkinCompliance(batch _: ObiSkinConstraintsBatch, constraintIndex _: Int) -> Float {
        0
    }
}
