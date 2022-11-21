//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

final class AnimationColorCurve: IAnimationCurveCalculator {
    typealias V = Color

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Color, AnimationColorCurve>) {
        owner.defaultValue = Color()
        owner.fixedPoseValue = Color()
        owner.baseEvaluateData.value = Color()
        owner.crossEvaluateData.value = Color()
    }

    static func _lerpValue(_ src: Color, _ dest: Color, _ weight: Float, _ out: Color?) -> Color {
        Color.lerp(start: src, end: dest, t: weight)
    }

    static func _additiveValue(_ additive: Color, _ weight: Float, _ srcOut: Color) -> Color {
        srcOut + additive * weight
    }

    static func _subtractValue(_ src: Color, _ base: Color, _ out: Color?) -> Color {
        src - base
    }

    static func _getZeroValue(_ out: Color?) -> Color {
        Color(0, 0, 0, 0)
    }

    static func _copyValue(_ src: Color, _ out: Color?) -> Color {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Color>, _ nextFrame: Keyframe<Color>, _ t: Float, _ dur: Float, _ out: Color?) -> Color {
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

        var outColor = SIMD4<Float>()
        var t0 = tan0.x
        var t1 = tan1.x
        if (t0.isFinite && t1.isFinite) {
            outColor.x = a * p0.r + b * t0 * dur + c * t1 * dur + d * p1.r
        } else {
            outColor.x = p0.r
        }

        t0 = tan0.y
        t1 = tan1.y
        if (t0.isFinite && t1.isFinite) {
            outColor.y = a * p0.g + b * t0 * dur + c * t1 * dur + d * p1.g
        } else {
            outColor.y = p0.g
        }

        t0 = tan0.z
        t1 = tan1.z
        if (t0.isFinite && t1.isFinite) {
            outColor.z = a * p0.b + b * t0 * dur + c * t1 * dur + d * p1.b
        } else {
            outColor.z = p0.b
        }

        t0 = tan0.w
        t1 = tan1.w
        if (t0.isFinite && t1.isFinite) {
            outColor.w = a * p0.a + b * t0 * dur + c * t1 * dur + d * p1.a
        } else {
            outColor.w = p0.a
        }

        return Color(outColor)
    }
}