//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiCatmullRomInterpolator: ObiInterpolator {
    public typealias T = Float

    public func Evaluate(v0: Float, v1: Float, v2: Float, v3: Float, mu: Float) -> Float {
        let imu = 1 - mu
        return imu * imu * imu * v0 +
            3 * imu * imu * mu * v1 +
            3 * imu * mu * mu * v2 +
            mu * mu * mu * v3
    }

    public func EvaluateFirstDerivative(v0: Float, v1: Float, v2: Float, v3: Float, mu: Float) -> Float {
        let imu = 1 - mu
        return 3 * imu * imu * (v1 - v0) +
            6 * imu * mu * (v2 - v1) +
            3 * mu * mu * (v3 - v2)
    }

    public func EvaluateSecondDerivative(v0: Float, v1: Float, v2: Float, v3: Float, mu: Float) -> Float {
        let imu = 1 - mu
        return 3 * imu * imu * (v1 - v0) +
            6 * imu * mu * (v2 - v1) +
            3 * mu * mu * (v3 - v2)
    }
}
