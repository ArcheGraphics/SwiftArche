//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

final class AnimationVector2Curve: IAnimationCurveCalculator {
    typealias V = Vector2

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Vector2, AnimationVector2Curve>) {
        owner.defaultValue = Vector2()
        owner.fixedPoseValue = Vector2()
        owner.baseEvaluateData.value = Vector2()
        owner.crossEvaluateData.value = Vector2()
    }

    static func _lerpValue(_ src: Vector2, _ dest: Vector2, _ weight: Float, _ out: Vector2?) -> Vector2 {
        Vector2.lerp(left: src, right: dest, t: weight)
    }

    static func _additiveValue(_ additive: Vector2, _ weight: Float, _ srcOut: Vector2) -> Vector2 {
        srcOut + additive * weight
    }

    static func _subtractValue(_ src: Vector2, _ base: Vector2, _ out: Vector2?) -> Vector2 {
        src - base
    }

    static func _getZeroValue(_ out: Vector2?) -> Vector2 {
        Vector2()
    }

    static func _copyValue(_ src: Vector2, _ out: Vector2?) -> Vector2 {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Vector2>, _ nextFrame: Keyframe<Vector2>,
                                           _ t: Float, _ dur: Float, _ out: Vector2?) -> Vector2 {
        let p0 = frame.value!
        let tan0 = frame.outTangent!
        let p1 = nextFrame.value!
        let tan1 = nextFrame.inTangent!

        let t2 = t * t
        let t3 = t2 * t
        let a = 2.0 * t3 - 3.0 * t2 + 1.0
        let b = t3 - 2.0 * t2 + t
        let c = t3 - t2
        let d = -2.0 * t3 + 3.0 * t2

        var outValue = SIMD2<Float>()
        var t0 = tan0.x
        var t1 = tan1.x
        if (t0.isFinite && t1.isFinite) {
            outValue.x = a * p0.x + b * t0 * dur + c * t1 * dur + d * p1.x
        } else {
            outValue.x = p0.x
        }

        t0 = tan0.y
        t1 = tan1.y
        if (t0.isFinite && t1.isFinite) {
            outValue.y = a * p0.y + b * t0 * dur + c * t1 * dur + d * p1.y
        } else {
            outValue.y = p0.y
        }

        return Vector2(outValue)
    }
}