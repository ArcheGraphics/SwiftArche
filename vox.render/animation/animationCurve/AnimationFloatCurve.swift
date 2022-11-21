//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

final class AnimationFloatCurve: IAnimationCurveCalculator {
    typealias V = Float

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Float, AnimationFloatCurve>) {
        owner.defaultValue = 0
        owner.fixedPoseValue = 0
        owner.baseEvaluateData.value = 0
        owner.crossEvaluateData.value = 0
    }

    static func _lerpValue(_ src: Float, _ dest: Float, _ weight: Float, _ out: Float?) -> Float {
        src + (dest - src) * weight
    }

    static func _additiveValue(_ additive: Float, _ weight: Float, _ srcOut: Float) -> Float {
        srcOut + additive * weight
    }

    static func _subtractValue(_ src: Float, _ base: Float, _ out: Float?) -> Float {
        src - base
    }

    static func _getZeroValue(_ out: Float?) -> Float {
        0
    }

    static func _copyValue(_ src: Float, _ out: Float?) -> Float {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Float>, _ nextFrame: Keyframe<Float>,
                                           _ t: Float, _ dur: Float, _ out: Float?) -> Float {
        let t0 = frame.outTangent!
        let t1 = nextFrame.inTangent!
        if (t0.isFinite && t1.isFinite) {
            let t2 = t * t
            let t3 = t2 * t
            let a = 2.0 * t3 - 3.0 * t2 + 1.0
            let b = t3 - 2.0 * t2 + t
            let c = t3 - t2
            let d = -2.0 * t3 + 3.0 * t2
            return a * frame.value + b * t0 * dur + c * t1 * dur + d * nextFrame.value
        } else {
            return frame.value
        }
    }
}