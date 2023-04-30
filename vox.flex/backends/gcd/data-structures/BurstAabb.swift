//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstAabb {
    public var min: float4
    public var max: float4

    public var size: float4 { return max - min }

    public var center: float4 { return min + (max - min) * 0.5 }

    public init(min: float4, max: float4) {
        self.min = min
        self.max = max
    }

    public init(v1: float4, v2: float4, v3: float4, margin: Float) {
        min = simd_min(simd_min(v1, v2), v3) - float4(margin, margin, margin, 0)
        max = simd_max(simd_max(v1, v2), v3) + float4(margin, margin, margin, 0)
    }

    public init(v1: float2, v2: float2, margin: Float) {
        min = float4(lowHalf: simd_min(v1, v2) - float2(margin, margin), highHalf: float2(0, 0))
        max = float4(lowHalf: simd_max(v1, v2) + float2(margin, margin), highHalf: float2(0, 0))
    }

    public init(previousPosition: float4, position: float4, radius: Float) {
        min = simd_min(position - radius, previousPosition - radius)
        max = simd_max(position + radius, previousPosition + radius)
    }

    public func AverageAxisLength() -> Float {
        let d = max - min
        return (d.x + d.y + d.z) * 0.33
    }

    public func MaxAxisLength() -> Float {
        return simd_reduce_max(max - min)
    }

    public mutating func EncapsulateParticle(position: float4, radius: Float) {
        min = simd_min(min, position - radius)
        max = simd_max(max, position + radius)
    }

    public mutating func EncapsulateParticle(previousPosition: float4, position: float4, radius: Float)
    {
        min = simd_min(simd_min(min, position - radius), previousPosition - radius)
        max = simd_max(simd_max(max, position + radius), previousPosition + radius)
    }

    public mutating func EncapsulateBounds(bounds: BurstAabb) {
        min = simd_min(min, bounds.min)
        max = simd_max(max, bounds.max)
    }

    public mutating func Expand(amount: float4) {
        min -= amount
        max += amount
    }

    public mutating func Sweep(velocity: float4) {
        min = simd_min(min, min + velocity)
        max = simd_max(max, max + velocity)
    }

    public func Transform(transform _: BurstAffineTransform) {}

    public func Transform(transform _: float4x4) {}

    public func Transformed(transform _: BurstAffineTransform) -> BurstAabb {
        BurstAabb(min: float4(), max: float4())
    }

    public func Transformed(transform _: float4x4) -> BurstAabb {
        BurstAabb(min: float4(), max: float4())
    }

    public func IntersectsAabb(bounds _: BurstAabb, in2D _: Bool = false) -> Bool {
        false
    }

    public func IntersectsRay(origin _: float4, inv_dir _: float4, in2D _: Bool = false) -> Bool {
        false
    }
}
