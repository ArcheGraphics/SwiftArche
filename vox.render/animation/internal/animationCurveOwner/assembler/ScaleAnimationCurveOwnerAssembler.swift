//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class ScaleAnimationCurveOwnerAssembler {
    private var _transform: Transform!

    public func initialize(owner: AnimationCurveOwner<Vector3>) {
        _transform = owner.target.transform;
    }

    public func getTargetValue() -> Vector3 {
        return _transform.scale;
    }

    public func setTargetValue(value: Vector3) {
        _transform.scale = value;
    }
}

extension ScaleAnimationCurveOwnerAssembler: IAnimationCurveOwnerAssembler {
}