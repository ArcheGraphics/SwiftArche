//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiPathDataChannelIdentity<T, Interpolator: ObiInterpolator>:
    ObiPathDataChannel<T, Interpolator> where Interpolator.T == T
{
    override public init(interpolator: Interpolator) {
        super.init(interpolator: interpolator)
    }

    public func GetFirstDerivative(index: Int) -> T {
        let nextCP = (index + 1) % Count

        return EvaluateFirstDerivative(v0: self[index],
                                       v1: self[index],
                                       v2: self[nextCP],
                                       v3: self[nextCP], mu: 0)
    }

    public func GetSecondDerivative(index: Int) -> T {
        let nextCP = (index + 1) % Count

        return EvaluateSecondDerivative(v0: self[index],
                                        v1: self[index],
                                        v2: self[nextCP],
                                        v3: self[nextCP], mu: 0)
    }

    public func GetAtMu(closed: Bool, mu: Float) -> T? {
        let cps = Count
        if cps >= 2 {
            var p: Float = 0
            let i = GetSpanControlPointAtMu(closed: closed, mu: mu, spanMu: &p)
            let nextCP = (i + 1) % cps

            return Evaluate(v0: self[i],
                            v1: self[i],
                            v2: self[nextCP],
                            v3: self[nextCP], mu: p)
        } else {
            return nil
        }
    }

    public func GetFirstDerivativeAtMu(closed: Bool, mu: Float) -> T? {
        let cps = Count
        if cps >= 2 {
            var p: Float = 0
            let i = GetSpanControlPointAtMu(closed: closed, mu: mu, spanMu: &p)
            let nextCP = (i + 1) % cps

            return EvaluateFirstDerivative(v0: self[i],
                                           v1: self[i],
                                           v2: self[nextCP],
                                           v3: self[nextCP], mu: p)
        } else {
            return nil
        }
    }

    public func GetSecondDerivativeAtMu(closed: Bool, mu: Float) -> T? {
        let cps = Count
        if cps >= 2 {
            var p: Float = 0
            let i = GetSpanControlPointAtMu(closed: closed, mu: mu, spanMu: &p)
            let nextCP = (i + 1) % cps

            return EvaluateSecondDerivative(v0: self[i],
                                            v1: self[i],
                                            v2: self[nextCP],
                                            v3: self[nextCP], mu: p)
        } else {
            return nil
        }
    }
}
