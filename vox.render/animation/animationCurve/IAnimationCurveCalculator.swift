//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol IAnimationCurveCalculator {
    associatedtype V: KeyframeValueType

    static var _isReferenceType: Bool { get }
    static var _isInterpolationType: Bool { get }

    static func _initializeOwner(_ owner: AnimationCurveOwner<V, Self>)

    static func _lerpValue(_ src: V, _ dest: V, _ weight: Float, _ out: V?) -> V
    static func _additiveValue(_ additive: V, _ weight: Float, _ srcOut: V) -> V
    static func _subtractValue(_ src: V, _ base: V, _ out: V?) -> V
    static func _getZeroValue(_ out: V?) -> V
    static func _copyValue(_ src: V, _ out: V?) -> V
    static func _hermiteInterpolationValue(_ frame: Keyframe<V>, _ nextFrame: Keyframe<V>, _ t: Float, _ dur: Float, _ out: V?) -> V
}