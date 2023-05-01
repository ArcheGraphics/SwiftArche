//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiCatmullRomInterpolator3D: ObiInterpolator {
    public typealias T = Vector3
    private var interpolator = ObiCatmullRomInterpolator()

    public func Evaluate(v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, mu: Float) -> Vector3 {
        return Vector3(interpolator.Evaluate(v0: v0.x, v1: v1.x, v2: v2.x, v3: v3.x, mu: mu),
                       interpolator.Evaluate(v0: v0.y, v1: v1.y, v2: v2.y, v3: v3.y, mu: mu),
                       interpolator.Evaluate(v0: v0.z, v1: v1.z, v2: v2.z, v3: v3.z, mu: mu))
    }

    public func EvaluateFirstDerivative(v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, mu: Float) -> Vector3 {
        return Vector3(interpolator.EvaluateFirstDerivative(v0: v0.x, v1: v1.x, v2: v2.x, v3: v3.x, mu: mu),
                       interpolator.EvaluateFirstDerivative(v0: v0.y, v1: v1.y, v2: v2.y, v3: v3.y, mu: mu),
                       interpolator.EvaluateFirstDerivative(v0: v0.z, v1: v1.z, v2: v2.z, v3: v3.z, mu: mu))
    }

    public func EvaluateSecondDerivative(v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, mu: Float) -> Vector3 {
        return Vector3(interpolator.EvaluateSecondDerivative(v0: v0.x, v1: v1.x, v2: v2.x, v3: v3.x, mu: mu),
                       interpolator.EvaluateSecondDerivative(v0: v0.y, v1: v1.y, v2: v2.y, v3: v3.y, mu: mu),
                       interpolator.EvaluateSecondDerivative(v0: v0.z, v1: v1.z, v2: v2.z, v3: v3.z, mu: mu))
    }
}
