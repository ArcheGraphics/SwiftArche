//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/**
 * Store a collection of Keyframes that can be evaluated over time.
 */
public class AnimationCurve<InterpolableValue: KeyframeValueType> {
    /** All keys defined in the animation curve. */
    var keys: [Keyframe<InterpolableValue>] = []
    /** The interpolationType of the animation curve. */
    var interpolation: InterpolationType!

    private var _tempValue: InterpolableValue!
    private var _length: Float = 0
    private var _currentIndex: Int = 0

    /// Animation curve length in seconds.
    var length: Float {
        get {
            _length
        }
    }
}