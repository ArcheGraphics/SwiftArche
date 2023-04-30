//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstInertialFrame {
    public var frame: BurstAffineTransform
    public var prevFrame: BurstAffineTransform

    public var velocity: float4
    public var angularVelocity: float4

    public var acceleration: float4
    public var angularAcceleration: float4

    public init(position: float4, scale: float4, rotation: quaternion) {
        frame = BurstAffineTransform(translation: position, rotation: rotation, scale: scale)
        prevFrame = frame

        velocity = float4.zero
        angularVelocity = float4.zero
        acceleration = float4.zero
        angularAcceleration = float4.zero
    }

    public init(frame: BurstAffineTransform) {
        self.frame = frame
        prevFrame = frame

        velocity = float4.zero
        angularVelocity = float4.zero
        acceleration = float4.zero
        angularAcceleration = float4.zero
    }

    public func Update(position _: float4, scale _: float4, rotation _: quaternion, dt _: Float) {}
}
