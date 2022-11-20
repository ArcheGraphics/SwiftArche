//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class RotationAnimationCurveOwnerAssembler {
    private var _transform: Transform!

    func initialize(owner: AnimationCurveOwner<Quaternion>) {
        _transform = owner.target.transform;
    }

    func getTargetValue() -> Quaternion {
        _transform.rotationQuaternion;
    }

    func setTargetValue(value: Quaternion) {
        _transform.rotationQuaternion = value;
    }
}

extension RotationAnimationCurveOwnerAssembler: IAnimationCurveOwnerAssembler {
}