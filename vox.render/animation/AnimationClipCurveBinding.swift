//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class AnimationClipCurveBindingBase {
    /// The name or path to the property being animated.
    var property: AnimationProperty!
    /// Path to the entity this curve applies to. The relativePath is formatted similar to a pathname,
    /// * e.g. "root/spine/leftArm". If relativePath is empty it refers to the entity the animation clip is attached to.
    var relativePath: String!
}

/// Associate AnimationCurve and the Entity
class AnimationClipCurveBinding<V: KeyframeValueType, Calculator: IAnimationCurveCalculator>:
    AnimationClipCurveBindingBase where Calculator.V == V {
    /// The class type of the component that is animated.
    var type: Component.Type!
    /// The animation curve.
    var curve: AnimationCurve<V, Calculator>!

    private var _tempCurveOwner: [Int: AnimationCurveOwner<V, Calculator>] = [:]

    func _createCurveOwner(_ entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == Vector3 {
        if property! == .Position {
            let owner = AnimationCurveOwner<Vector3, Calculator>(entity, property, PositionAnimationCurveOwnerAssembler<Calculator>())
            Calculator._initializeOwner(owner)
            return owner
        } else {
            let owner = AnimationCurveOwner<Vector3, Calculator>(entity, property, ScaleAnimationCurveOwnerAssembler<Calculator>())
            Calculator._initializeOwner(owner)
            return owner
        }
    }

    func _createCurveOwner(_ entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == Quaternion {
        let owner = AnimationCurveOwner<Quaternion, Calculator>(entity, property, RotationAnimationCurveOwnerAssembler<Calculator>())
        Calculator._initializeOwner(owner)
        return owner
    }
    
    func _createCurveOwner(_ entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == [Float] {
        let owner = AnimationCurveOwner<[Float], Calculator>(entity, property, BlendShapeWeightsAnimationCurveOwnerAssembler<Calculator>())
        Calculator._initializeOwner(owner)
        return owner
    }

    func _getTempCurveOwner(entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == Vector3 {
        let instanceId = entity.instanceId
        if (_tempCurveOwner[instanceId] == nil) {
            _tempCurveOwner[instanceId] = _createCurveOwner(entity)
        }
        return _tempCurveOwner[instanceId]!
    }

    func _getTempCurveOwner(entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == Quaternion {
        let instanceId = entity.instanceId
        if (_tempCurveOwner[instanceId] == nil) {
            _tempCurveOwner[instanceId] = _createCurveOwner(entity)
        }
        return _tempCurveOwner[instanceId]!
    }
    
    func _getTempCurveOwner(entity: Entity) -> AnimationCurveOwner<V, Calculator> where Calculator.V == [Float] {
        let instanceId = entity.instanceId
        if (_tempCurveOwner[instanceId] == nil) {
            _tempCurveOwner[instanceId] = _createCurveOwner(entity)
        }
        return _tempCurveOwner[instanceId]!
    }
}
