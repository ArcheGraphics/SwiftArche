//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

internal class AnimationCurveOwner {
    var crossCurveMark: Int = 0
    var crossCurveIndex: Int!

    var target: Entity
    var type: Component.Type
    var property: AnimationProperty
    var component: Component
    var defaultValue: InterpolableValue
    var fixedPoseValue: InterpolableValue

    init(_ target: Entity, _ type: Component.Type, _ property: AnimationProperty) {
        self.target = target
        self.type = type
        self.property = property
        switch (property) {
        case AnimationProperty.Position:
            defaultValue = .Vector3(Vector3())
            fixedPoseValue = .Vector3(Vector3())
            component = target.transform
            break
        case AnimationProperty.Rotation:
            defaultValue = .Quaternion(Quaternion())
            fixedPoseValue = .Quaternion(Quaternion())
            component = target.transform
            break
        case AnimationProperty.Scale:
            defaultValue = .Vector3(Vector3())
            fixedPoseValue = .Vector3(Vector3())
            component = target.transform
            break
//        case AnimationProperty.BlendShapeWeights:
//            defaultValue = .FloatArray([Float](repeating: 0, count: 4))
//            fixedPoseValue = .FloatArray([Float](repeating: 0, count: 4))
//            let skinnedMesh: SkinnedMeshRenderer = target.getComponent()
//            component = skinnedMesh
//            break
        }
    }

    func saveDefaultValue() {
        switch (property) {
        case AnimationProperty.Position:
            switch defaultValue {
            case .Vector3:
                defaultValue = .Vector3(target.transform.position)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Rotation:
            switch defaultValue {
            case .Quaternion:
                defaultValue = .Quaternion(target.transform.rotationQuaternion)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Scale:
            switch defaultValue {
            case .Vector3:
                defaultValue = .Vector3(target.transform.scale)
            default:
                fatalError()
            }
            break
        }
    }

    func saveFixedPoseValue() {
        switch (property) {
        case AnimationProperty.Position:
            switch fixedPoseValue {
            case .Vector3:
                defaultValue = .Vector3(target.transform.position)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Rotation:
            switch fixedPoseValue {
            case .Quaternion:
                defaultValue = .Quaternion(target.transform.rotationQuaternion)
            default:
                fatalError()
            }
            break
        case AnimationProperty.Scale:
            switch fixedPoseValue {
            case .Vector3:
                defaultValue = .Vector3(target.transform.scale)
            default:
                fatalError()
            }
            break
        }
    }
}
