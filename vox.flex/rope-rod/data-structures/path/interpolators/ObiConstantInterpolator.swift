//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiConstantInterpolator: ObiInterpolator {
    public typealias T = Int

    /// constant interpolator
    public func Evaluate(v0 _: Int, v1: Int, v2: Int, v3 _: Int, mu: Float) -> Int {
        mu < 0.5 ? v1 : v2
    }

    /// derivative of constant value:
    public func EvaluateFirstDerivative(v0 _: Int, v1 _: Int, v2 _: Int, v3 _: Int, mu _: Float) -> Int {
        0
    }

    /// second derivative of constant value:
    public func EvaluateSecondDerivative(v0 _: Int, v1 _: Int, v2 _: Int, v3 _: Int, mu _: Float) -> Int {
        0
    }
}
