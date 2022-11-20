//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class AnimationCurveOwner<InterpolableValue: KeyframeValueType> {
    var crossCurveMark: Int = 0
    var crossCurveIndex: Int!

    var target: Entity
    var property: AnimationProperty
    var component: Component
    var defaultValue: InterpolableValue
    var fixedPoseValue: InterpolableValue
    var _hasSavedDefaultValue: Bool = false

    init(_ target: Entity, _ property: AnimationProperty) {
        self.target = target
        self.property = property
        switch (property) {
        case AnimationProperty.Position:
            defaultValue = Vector3() as! InterpolableValue
            fixedPoseValue = Vector3() as! InterpolableValue
            component = target.transform
            break
        case AnimationProperty.Rotation:
            defaultValue = Quaternion() as! InterpolableValue
            fixedPoseValue = Quaternion() as! InterpolableValue
            component = target.transform
            break
        case AnimationProperty.Scale:
            defaultValue = Vector3() as! InterpolableValue
            fixedPoseValue = Vector3() as! InterpolableValue
            component = target.transform
            break
//        case AnimationProperty.BlendShapeWeights:
//            break
        }
    }
}