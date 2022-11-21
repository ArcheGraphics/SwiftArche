//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

final class AnimationArrayCurve: IAnimationCurveCalculator {
    typealias V = Array<Float>

    static var _isReferenceType: Bool = false

    static var _isInterpolationType: Bool = true

    static func _initializeOwner(_ owner: AnimationCurveOwner<Array<Float>, AnimationArrayCurve>) {
        owner.defaultValue = []
        owner.fixedPoseValue = []
        owner.baseEvaluateData.value = []
        owner.crossEvaluateData.value = []
    }

    static func _lerpValue(_ src: Array<Float>, _ dest: Array<Float>, _ weight: Float, _ out: Array<Float>?) -> Array<Float> {
        var out = [Float](repeating: 0, count: src.count)
        for i in 0..<src.count {
            let srcValue = src[i]
            out[i] = srcValue + (dest[i] - srcValue) * weight
        }
        return out
    }

    static func _additiveValue(_ additive: Array<Float>, _ weight: Float, _ srcOut: Array<Float>) -> Array<Float> {
        var out = [Float](repeating: 0, count: srcOut.count)
        for i in 0..<srcOut.count {
            out[i] = srcOut[i] + additive[i] * weight
        }
        return out
    }

    static func _subtractValue(_ src: Array<Float>, _ base: Array<Float>, _ out: Array<Float>?) -> Array<Float> {
        var out = [Float](repeating: 0, count: src.count)
        for i in 0..<src.count {
            out[i] = src[i] - base[i]
        }
        return out
    }

    static func _getZeroValue(_ out: Array<Float>?) -> Array<Float> {
        [Float](repeating: 0, count: out?.count ?? 0)
    }

    static func _copyValue(_ src: Array<Float>, _ out: Array<Float>?) -> Array<Float> {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Array<Float>>, _ nextFrame: Keyframe<Array<Float>>,
                                           _ t: Float, _ dur: Float, _ out: Array<Float>?) -> Array<Float> {
        let t0 = frame.outTangent!
        let t1 = nextFrame.inTangent!
        let p0 = frame.value!
        let p1 = nextFrame.value!

        let t2 = t * t
        let t3 = t2 * t
        let a = 2.0 * t3 - 3.0 * t2 + 1.0
        let b = t3 - 2.0 * t2 + t
        let c = t3 - t2
        let d = -2.0 * t3 + 3.0 * t2

        var out = [Float](repeating: 0, count: p0.count)
        for i in 0..<p0.count {
            if (t0[i].isFinite && t1[i].isFinite) {
                out[i] = a * p0[i] + b * t0[i] * dur + c * t1[i] * dur + d * p1[i]
            } else {
                out[i] = frame.value[i]
            }
        }
        return out
    }
}