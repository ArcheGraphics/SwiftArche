//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public final class BlendShapeWeightsAnimationCurveOwnerAssembler<Calculator: IAnimationCurveCalculator>:
        IAnimationCurveOwnerAssembler<[Float], Calculator> where Calculator.V == [Float] {
    private var _renderers: [SkinnedMeshRenderer] = []
    private var _targetValue: [Float] = []

    public override func initialize(owner: AnimationCurveOwner<[Float], Calculator>) {
        _renderers = owner.target.getComponents()
    }

    public override func getTargetValue() -> [Float]? {
        _targetValue
    }

    public override func setTargetValue(_ value: [Float]) {
        _targetValue = value
        for renderer in _renderers {
            renderer.blendShapeWeights = value
        }
    }
}
