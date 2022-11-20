//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Store a collection of Keyframes that can be evaluated over time.
public class AnimationCurve<V: KeyframeValueType, Calculator: IAnimationCurveCalculator> where Calculator.V == V {
    /// All keys defined in the animation curve.
    var keys: [Keyframe<V>] = []

    var _evaluateData: IEvaluateData<V> = IEvaluateData()
    var _length: Float = 0
    var _interpolation: InterpolationType

    private var _type: Calculator.Type

    /// The interpolationType of the animation curve.
    var interpolation: InterpolationType {
        get {
            _interpolation
        }
        set {
            if (!_type._isInterpolationType && newValue != InterpolationType.Step) {
                _interpolation = InterpolationType.Step
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

    init(type: Calculator.Type) {
        _interpolation = type._isInterpolationType ? InterpolationType.Linear : InterpolationType.Step
        _type = type
    }

}