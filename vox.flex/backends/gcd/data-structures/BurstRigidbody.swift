//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstRigidbody {
    public var inverseInertiaTensor: float4x4
    public var velocity: float4
    public var angularVelocity: float4
    public var com: float4
    public var inverseMass: Float
}
