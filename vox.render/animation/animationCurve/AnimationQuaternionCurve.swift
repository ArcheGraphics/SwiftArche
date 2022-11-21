//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

final class AnimationQuaternionCurve: IAnimationCurveCalculator {
    typealias V = Quaternion

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Quaternion, AnimationQuaternionCurve>) {
        owner.defaultValue = Quaternion()
        owner.fixedPoseValue = Quaternion()
        owner.baseEvaluateData.value = Quaternion()
        owner.crossEvaluateData.value = Quaternion()
    }

    static func _lerpValue(_ src: Quaternion, _ dest: Quaternion, _ weight: Float, _ out: Quaternion?) -> Quaternion {
        Quaternion.slerp(start: src, end: dest, t: weight)
    }

    static func _additiveValue(_ additive: Quaternion, _ weight: Float, _ srcOut: Quaternion) -> Quaternion {
        srcOut * additive * weight
    }

    static func _subtractValue(_ src: Quaternion, _ base: Quaternion, _ out: Quaternion?) -> Quaternion {
        Quaternion.conjugate(a: base) * src
    }

    static func _getZeroValue(_ out: Quaternion?) -> Quaternion {
        Quaternion()
    }

    static func _copyValue(_ src: Quaternion, _ out: Quaternion?) -> Quaternion {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Quaternion>, _ nextFrame: Keyframe<Quaternion>,
                                           _ t: Float, _ dur: Float, _ out: Quaternion?) -> Quaternion {
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

        var outValue = simd_quatf()
        var t0 = tan0.x
        var t1 = tan1.x
        if (t0.isFinite && t1.isFinite) {
            outValue.imag.x = a * p0.x + b * t0 * dur + c * t1 * dur + d * p1.x
        } else {
            outValue.imag.x = p0.x
        }

        t0 = tan0.y
        t1 = tan1.y
        if (t0.isFinite && t1.isFinite) {
            outValue.imag.y = a * p0.y + b * t0 * dur + c * t1 * dur + d * p1.y
        } else {
            outValue.imag.y = p0.y
        }

        t0 = tan0.z
        t1 = tan1.z
        if (t0.isFinite && t1.isFinite) {
            outValue.imag.z = a * p0.z + b * t0 * dur + c * t1 * dur + d * p1.z
        } else {
            outValue.imag.z = p0.z
        }

        t0 = tan0.w
        t1 = tan1.w
        if (t0.isFinite && t1.isFinite) {
            outValue.real = a * p0.w + b * t0 * dur + c * t1 * dur + d * p1.w
        } else {
            outValue.real = p0.w
        }
        return Quaternion(outValue)
    }
}