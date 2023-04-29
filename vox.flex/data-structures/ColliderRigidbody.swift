//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ColliderRigidbody {
    public var inverseInertiaTensor: Matrix
    public var velocity: Vector4
    public var angularVelocity: Vector4
    public var com: Vector4
    public var inverseMass: Float
}
