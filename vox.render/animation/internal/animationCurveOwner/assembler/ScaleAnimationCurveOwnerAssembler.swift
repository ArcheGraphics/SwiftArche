//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public final class ScaleAnimationCurveOwnerAssembler<Calculator: IAnimationCurveCalculator>:
        IAnimationCurveOwnerAssembler<Vector3, Calculator> where Calculator.V == Vector3 {
    private var _transform: Transform!

    public override func initialize(owner: AnimationCurveOwner<Vector3, Calculator>) {
        _transform = owner.target.transform
    }

    public override func getTargetValue() -> Vector3? {
        _transform.scale
    }

    public override func setTargetValue(_ value: Vector3) {
        _transform.scale = value
    }
}