//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public enum BurstIntegration {
    public static func IntegrateLinear(position: float4, velocity: float4, dt: Float) -> float4 {
        return position + velocity * dt
    }

    public static func DifferentiateLinear(position: float4, prevPosition: float4, dt: Float) -> float4
    {
        return (position - prevPosition) / dt
    }

    public static func AngularVelocityToSpinQuaternion(rotation _: quaternion, angularVelocity _: float4, dt _: Float) -> quaternion
    {
        quaternion()
    }

    public static func IntegrateAngular(rotation _: quaternion, angularVelocity _: float4, dt _: Float) -> quaternion
    {
        quaternion()
    }

    public static func DifferentiateAngular(rotation _: quaternion, prevRotation _: quaternion, dt _: Float) -> float4 {
        float4()
    }
}
