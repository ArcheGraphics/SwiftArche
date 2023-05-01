//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiColorInterpolator3D: ObiInterpolator {
    public typealias T = Color
    private var interpolator = ObiCatmullRomInterpolator()

    public func Evaluate(v0: Color, v1: Color, v2: Color, v3: Color, mu: Float) -> Color {
        return Color(interpolator.Evaluate(v0: v0.r, v1: v1.r, v2: v2.r, v3: v3.r, mu: mu),
                     interpolator.Evaluate(v0: v0.g, v1: v1.g, v2: v2.g, v3: v3.g, mu: mu),
                     interpolator.Evaluate(v0: v0.b, v1: v1.b, v2: v2.b, v3: v3.b, mu: mu),
                     interpolator.Evaluate(v0: v0.a, v1: v1.a, v2: v2.a, v3: v3.a, mu: mu))
    }

    public func EvaluateFirstDerivative(v0: Color, v1: Color, v2: Color, v3: Color, mu: Float) -> Color {
        return Color(interpolator.EvaluateFirstDerivative(v0: v0.r, v1: v1.r, v2: v2.r, v3: v3.r, mu: mu),
                     interpolator.EvaluateFirstDerivative(v0: v0.g, v1: v1.g, v2: v2.g, v3: v3.g, mu: mu),
                     interpolator.EvaluateFirstDerivative(v0: v0.b, v1: v1.b, v2: v2.b, v3: v3.b, mu: mu),
                     interpolator.EvaluateFirstDerivative(v0: v0.a, v1: v1.a, v2: v2.a, v3: v3.a, mu: mu))
    }

    public func EvaluateSecondDerivative(v0: Color, v1: Color, v2: Color, v3: Color, mu: Float) -> Color {
        return Color(interpolator.EvaluateSecondDerivative(v0: v0.r, v1: v1.r, v2: v2.r, v3: v3.r, mu: mu),
                     interpolator.EvaluateSecondDerivative(v0: v0.g, v1: v1.g, v2: v2.g, v3: v3.g, mu: mu),
                     interpolator.EvaluateSecondDerivative(v0: v0.b, v1: v1.b, v2: v2.b, v3: v3.b, mu: mu),
                     interpolator.EvaluateSecondDerivative(v0: v0.a, v1: v1.a, v2: v2.a, v3: v3.a, mu: mu))
    }
}
