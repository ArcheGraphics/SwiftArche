//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol IAnimationCurveCalculator {
    associatedtype V: KeyframeValueType

    static var _isReferenceType: Bool { get set }
    static var _isInterpolationType: Bool { get set }

    static func _initializeOwner(owner: AnimationCurveOwner<V>)
    static func _lerpValue(src: V, dest: V, weight: Float, out: V?) -> V
    static func _additiveValue(additive: V, weight: Float, srcOut: V) -> V
    static func _subtractValue(src: V, base: V, out: V?) -> V
    static func _getZeroValue(out: V?) -> V
    static func _copyValue(src: V, out: V?) -> V
    static func _hermiteInterpolationValue(frame: Keyframe<V>, nextFrame: Keyframe<V>, t: Float, dur: Float, out: V?) -> V
}