//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Store a collection of Keyframes that can be evaluated over time.
class AnimationCurve<V: KeyframeValueType, Calculator: IAnimationCurveCalculator> where Calculator.V == V {
    /// All keys defined in the animation curve.
    var keys: [Keyframe<V>] = []

    var _evaluateData: IEvaluateData<V> = IEvaluateData()
    var _length: Float = 0
    var _interpolation: InterpolationType

    /// The interpolationType of the animation curve.
    var interpolation: InterpolationType {
        get {
            _interpolation
        }
        set {
            if (!Calculator._isInterpolationType && newValue != InterpolationType.Step) {
                _interpolation = InterpolationType.Step
                logger.warning("The interpolation type must be `InterpolationType.Step`.")
            } else {
                _interpolation = newValue
            }
        }
    }

    /// Animation curve length in seconds.
    var length: Float {
        get {
            _length
        }
    }

    init() {
        _interpolation = Calculator._isInterpolationType ? InterpolationType.Linear : InterpolationType.Step
    }

    /// Add a new key to the curve.
    /// - Parameter key: The keyframe
    func addKey(_ key: Keyframe<V>) {
        keys.append(key)
        if (key.time > _length) {
            _length = key.time
        }
        keys.sort { (a: Keyframe<V>, b: Keyframe<V>) in
            a.time - b.time > 0
        }
    }

    /// Evaluate the curve at time.
    /// - Parameter time: The time within the curve you want to evaluate
    func evaluate(_ time: Float) -> V {
        _evaluate(time, &_evaluateData)
    }

    /// Removes a key.
    /// - Parameter index: The index of the key to remove
    func removeKey(_ index: Int) {
        keys.remove(at: index)

        var newLength: Float = 0
        for key in keys {
            if (key.time > length) {
                newLength = key.time
            }
        }
        _length = newLength
    }

    func _evaluate(_ time: Float, _ evaluateData: inout IEvaluateData<V>) -> V {
        let length = keys.count
        guard length > 0 else {
            fatalError("This curve don't have any keyframes")
        }

        // Compute curIndex and nextIndex.
        var curIndex = evaluateData.curKeyframeIndex

        // Reset loop,if delete keyframe may cause `curIndex >= length`
        if (curIndex != -1 && (curIndex >= length || time < keys[curIndex].time)) {
            curIndex = -1
        }

        var nextIndex = curIndex + 1
        while (nextIndex < length) {
            if (time < keys[nextIndex].time) {
                break
            }
            curIndex += 1
            nextIndex += 1
        }
        evaluateData.curKeyframeIndex = curIndex

        // Evaluate value.
        let value: V
        if (curIndex == -1) {
            value = Calculator._copyValue(keys[0].value, evaluateData.value)
        } else if (nextIndex == length) {
            value = Calculator._copyValue(keys[curIndex].value, evaluateData.value)
        } else {
            // Time between first frame and end frame.
            let curFrame = keys[curIndex]
            let nextFrame = keys[nextIndex]
            let curFrameTime = curFrame.time
            let duration = nextFrame.time - curFrameTime
            let t = (time - curFrameTime) / duration

            switch (interpolation) {
            case InterpolationType.Linear:
                value = Calculator._lerpValue(curFrame.value, nextFrame.value, t, evaluateData.value)
                break
            case InterpolationType.Step:
                value = Calculator._copyValue(curFrame.value, evaluateData.value)
                break
            case InterpolationType.CubicSpine, InterpolationType.Hermite:
                value = Calculator._hermiteInterpolationValue(curFrame, nextFrame, t, duration, evaluateData.value)
                break
            }
        }
        return value
    }

    func _evaluateAdditive(_ time: Float, _ evaluateData: inout IEvaluateData<V>) -> V {
        let result = _evaluate(time, &evaluateData)
        return Calculator._subtractValue(result, keys[0].value, evaluateData.value)
    }
}
