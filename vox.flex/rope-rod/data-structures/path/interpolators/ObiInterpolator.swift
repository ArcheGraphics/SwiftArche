//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ObiInterpolator {
    associatedtype T
    func Evaluate(v0: T, v1: T, v2: T, v3: T, mu: Float) -> T
    func EvaluateFirstDerivative(v0: T, v1: T, v2: T, v3: T, mu: Float) -> T
    func EvaluateSecondDerivative(v0: T, v1: T, v2: T, v3: T, mu: Float) -> T
}
