//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

final class AnimationVector3Curve: IAnimationCurveCalculator {
    typealias V = Vector3

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Vector3, AnimationVector3Curve>) {
        owner.defaultValue = Vector3()
        owner.fixedPoseValue = Vector3()
        owner.baseEvaluateData.value = Vector3()
        owner.crossEvaluateData.value = Vector3()
    }

    static func _lerpValue(_ src: Vector3, _ dest: Vector3, _ weight: Float, _ out: Vector3?) -> Vector3 {
        Vector3.lerp(left: src, right: dest, t: weight)
    }

    static func _additiveValue(_ additive: Vector3, _ weight: Float, _ srcOut: Vector3) -> Vector3 {
        srcOut + additive * weight
    }

    static func _subtractValue(_ src: Vector3, _ base: Vector3, _ out: Vector3?) -> Vector3 {
        src - base
    }

    static func _getZeroValue(_ out: Vector3?) -> Vector3 {
        Vector3()
    }

    static func _copyValue(_ src: Vector3, _ out: Vector3?) -> Vector3 {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Vector3>, _ nextFrame: Keyframe<Vector3>,
                                           _ t: Float, _ dur: Float, _ out: Vector3?) -> Vector3 {
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

        var outValue = SIMD3<Float>()
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

        t0 = tan0.z
        t1 = tan1.z
        if (t0.isFinite && t1.isFinite) {
            outValue.z = a * p0.z + b * t0 * dur + c * t1 * dur + d * p1.z
        } else {
            outValue.z = p0.z
        }

        return Vector3(outValue)
    }
}