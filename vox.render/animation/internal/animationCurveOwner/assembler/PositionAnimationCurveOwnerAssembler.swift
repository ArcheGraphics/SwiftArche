//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class PositionAnimationCurveOwnerAssembler {
    private var _transform: Transform!

    public func initialize(owner: AnimationCurveOwner<Vector3>) {
        _transform = owner.target.transform
    }

    public func getTargetValue() -> Vector3 {
        _transform.position
    }

    public func setTargetValue(value: Vector3) {
        _transform.position = value
    }
}

extension PositionAnimationCurveOwnerAssembler: IAnimationCurveOwnerAssembler {
}