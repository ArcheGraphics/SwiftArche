//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class AnimationArrayCurve: IAnimationCurveCalculator {
    public typealias V = Array<Float>

    public static var _isReferenceType: Bool = false
    public static var _isInterpolationType: Bool = true

    public static func _initializeOwner(owner: AnimationCurveOwner<Array<Float>>) {
        owner.defaultValue = []
        owner.fixedPoseValue = []
        owner.baseEvaluateData.value = []
        owner.crossEvaluateData.value = []
    }

    public static func _lerpValue(src: Array<Float>, dest: Array<Float>, weight: Float, out: Array<Float>?) -> Array<Float> {
        var out = Array<Float>(repeating: 0, count: src.count)
        for i in 0..<src.count {
            let srcValue = src[i]
            out[i] = srcValue + (dest[i] - srcValue) * weight
        }
        return out
    }

    public static func _additiveValue(additive: Array<Float>, weight: Float, srcOut: Array<Float>) -> Array<Float> {
        var out = Array<Float>(repeating: 0, count: additive.count)
        for i in 0..<additive.count {
            out[i] = srcOut[i] + additive[i] * weight
        }
        return out
    }

    public static func _subtractValue(src: Array<Float>, base: Array<Float>, out: Array<Float>?) -> Array<Float> {
        var out = Array<Float>(repeating: 0, count: src.count)
        for i in 0..<src.count {
            out[i] = src[i] - base[i]
        }
        return out
    }

    public static func _getZeroValue(out: Array<Float>?) -> Array<Float> {
        [Float](repeating: 0, count: out?.count ?? 0)
    }

    public static func _copyValue(src: Array<Float>, out: Array<Float>?) -> Array<Float> {
        src
    }

    public static func _hermiteInterpolationValue(frame: Keyframe<Array<Float>>, nextFrame: Keyframe<Array<Float>>,
                                                  t: Float, dur: Float, out: Array<Float>?) -> Array<Float> {
        let t0 = frame.outTangent
        let t1 = nextFrame.inTangent
        let p0 = frame.value
        let p1 = nextFrame.value

        let t2: Float = t * t
        let t3: Float = t2 * t
        let a: Float = 2.0 * t3 - 3.0 * t2 + 1.0
        let b: Float = t3 - 2.0 * t2 + t
        let c: Float = t3 - t2
        let d: Float = -2.0 * t3 + 3.0 * t2

        var out = Array<Float>(repeating: 0, count: p0!.count)
        for i in 0..<p0!.count {
            if (t0 != nil && t1 != nil) {
                out[i] = a * p0![i] + b * t0![i] * dur + c * t1![i] * dur + d * p1![i]
            } else {
                out[i] = frame.value[i]
            }
        }
        return out
    }
}