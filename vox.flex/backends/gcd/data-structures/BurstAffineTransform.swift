//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstAffineTransform {
    public var translation: float4
    public var scale: float4
    public var rotation: quaternion

    public init(translation: float4, rotation: quaternion, scale: float4) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale

        // make sure there are good values in the 4th component:
        self.translation[3] = 0
        self.scale[3] = 1
    }

    public static func * (_: BurstAffineTransform, _: BurstAffineTransform) -> BurstAffineTransform {
        BurstAffineTransform(translation: float4(), rotation: quaternion(), scale: float4())
    }

    public func Inverse() -> BurstAffineTransform {
        BurstAffineTransform(translation: float4(), rotation: quaternion(), scale: float4())
    }

    public func Interpolate(other _: BurstAffineTransform, translationalMu _: Float,
                            rotationalMu _: Float, scaleMu _: Float) -> BurstAffineTransform
    {
        BurstAffineTransform(translation: float4(), rotation: quaternion(), scale: float4())
    }

    public func TransformPoint(point _: float4) -> float4 {
        float4()
    }

    public func InverseTransformPoint(point _: float4) -> float4 {
        float4()
    }

    public func TransformPointUnscaled(point _: float4) -> float4 {
        float4()
    }

    public func InverseTransformPointUnscaled(point _: float4) -> float4 {
        float4()
    }

    public func TransformDirection(direction _: float4) -> float4 {
        float4()
    }

    public func InverseTransformDirection(direction _: float4) -> float4 {
        float4()
    }

    public func TransformVector(vector _: float4) -> float4 {
        float4()
    }

    public func InverseTransformVector(vector _: float4) -> float4 {
        float4()
    }
}
