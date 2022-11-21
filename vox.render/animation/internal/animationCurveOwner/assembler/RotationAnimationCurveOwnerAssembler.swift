//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public final class RotationAnimationCurveOwnerAssembler<Calculator: IAnimationCurveCalculator>:
        IAnimationCurveOwnerAssembler<Quaternion, Calculator> where Calculator.V == Quaternion {
    private var _transform: Transform!

    public override func initialize(owner: AnimationCurveOwner<Quaternion, Calculator>) {
        _transform = owner.target.transform
    }

    public override func getTargetValue() -> Quaternion? {
        _transform.rotationQuaternion
    }

    public override func setTargetValue(_ value: Quaternion) {
        _transform.rotationQuaternion = value
    }
}