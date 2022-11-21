//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

final class AnimationBoolCurve: IAnimationCurveCalculator {
    typealias V = Bool

    static var _isReferenceType: Bool = false
    static var _isInterpolationType: Bool = false

    static func _initializeOwner(_ owner: AnimationCurveOwner<Bool, AnimationBoolCurve>) {
        owner.defaultValue = false
        owner.fixedPoseValue = false
        owner.baseEvaluateData.value = false
        owner.crossEvaluateData.value = false
    }

    static func _lerpValue(_ src: Bool, _ dest: Bool, _ weight: Float, _ out: Bool?) -> Bool {
        dest
    }

    static func _additiveValue(_ additive: Bool, _ weight: Float, _ srcOut: Bool) -> Bool {
        additive
    }

    static func _subtractValue(_ src: Bool, _ base: Bool, _ out: Bool?) -> Bool {
        src
    }

    static func _getZeroValue(_ out: Bool?) -> Bool {
        false
    }

    static func _copyValue(_ src: Bool, _ out: Bool?) -> Bool {
        src
    }

    static func _hermiteInterpolationValue(_ frame: Keyframe<Bool>, _ nextFrame: Keyframe<Bool>,
                                           _ t: Float, _ dur: Float, _ out: Bool?) -> Bool {
        frame.value
    }
}