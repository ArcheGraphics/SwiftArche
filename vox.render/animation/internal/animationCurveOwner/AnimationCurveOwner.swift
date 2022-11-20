//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class AnimationCurveOwner<V: KeyframeValueType> {
    let target: Entity
    var crossCurveMark: Int = 0
    var crossCurveDataIndex: Int!
    var defaultValue: V!
    var fixedPoseValue: V!
    var hasSavedDefaultValue: Bool = false
    var baseEvaluateData: IEvaluateData<V> = IEvaluateData()

    var crossEvaluateData: IEvaluateData<V> = IEvaluateData()
    var crossSrcCurveIndex: Int!
    var crossDestCurveIndex: Int!

    var referenceTargetValue: V!

    init(target: Entity) {
        self.target = target
    }
}

struct IEvaluateData<V: KeyframeValueType> {
    var curKeyframeIndex: Int = 0
    var value: V? = nil
}