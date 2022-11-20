//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class AnimationFloatCurve: IAnimationCurveCalculator {
    typealias V = Float

    static var _isReferenceType: Bool = false
    static var _isInterpolationType: Bool = true

    static func _initializeOwner(owner: AnimationCurveOwner<Float>) {
        owner.defaultValue = 0
        owner.fixedPoseValue = 0
        owner.baseEvaluateData.value = 0
        owner.crossEvaluateData.value = 0
    }

    static func _lerpValue(src: Float, dest: Float, weight: Float, out: Float?) -> Float {
        src + (dest - src) * weight
    }

    static func _additiveValue(additive: Float, weight: Float, srcOut: Float) -> Float {
        srcOut + additive * weight
    }

    static func _subtractValue(src: Float, base: Float, out: Float?) -> Float {
        src - base
    }

    static func _getZeroValue(out: Float?) -> Float {
        0
    }

    static func _copyValue(src: Float, out: Float?) -> Float {
        src
    }

    static func _hermiteInterpolationValue(frame: Keyframe<Float>, nextFrame: Keyframe<Float>, t: Float, dur: Float, out: Float?) -> Float {
        let t0 = frame.outTangent
        let t1 = nextFrame.inTangent
        if (t0 != nil && t1 != nil) {
            let t2: Float = t * t
            let t3: Float = t2 * t
            let a: Float = 2.0 * t3 - 3.0 * t2 + 1.0
            let b: Float = t3 - 2.0 * t2 + t
            let c: Float = t3 - t2
            let d: Float = -2.0 * t3 + 3.0 * t2
            return a * frame.value + b * t0! * dur + c * t1! * dur + d * nextFrame.value
        } else {
            return frame.value
        }
    }
}