//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class IAnimationCurveOwnerAssembler<V: KeyframeValueType, Calculator: IAnimationCurveCalculator> where Calculator.V == V {
    func initialize(owner: AnimationCurveOwner<V, Calculator>) {
    }

    func getTargetValue() -> V? {
        nil
    }

    func setTargetValue(_ value: V) {
    }
}