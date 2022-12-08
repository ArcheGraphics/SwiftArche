//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public final class BlendShapeWeightsAnimationCurveOwnerAssembler<Calculator: IAnimationCurveCalculator>:
        IAnimationCurveOwnerAssembler<[Float], Calculator> where Calculator.V == [Float] {
    private var _skinnedMeshRenderer: SkinnedMeshRenderer!

    public override func initialize(owner: AnimationCurveOwner<[Float], Calculator>) {
        _skinnedMeshRenderer = owner.target.getComponent()
    }

    public override func getTargetValue() -> [Float]? {
        _skinnedMeshRenderer.blendShapeWeights
    }

    public override func setTargetValue(_ value: [Float]) {
        _skinnedMeshRenderer.blendShapeWeights = value
    }
}
