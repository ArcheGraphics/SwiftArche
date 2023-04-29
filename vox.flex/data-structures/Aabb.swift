//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct Aabb {
    public var min: Vector4
    public var max: Vector4

    public var center: Vector4 { return min + (max - min) * 0.5 }

    public var size: Vector4 { return max - min }

    public init(min: Vector4, max: Vector4) {
        self.min = min
        self.max = max
    }

    public init(point: Vector4) {
        self.min = point
        self.max = point
    }

    public mutating func Encapsulate(point: Vector4) {
        min = Vector4.min(left: min, right: point)
        max = Vector4.max(left: max, right: point)
    }

    public mutating func Encapsulate(other: Aabb) {
        min = Vector4.min(left: min, right: other.min)
        max = Vector4.max(left: max, right: other.max)
    }

    public mutating func FromBounds(bounds: Bounds, thickness: Float, is2D: Bool = false) {
        let s = Vector3.one * thickness
        min = Vector4(bounds.min - s, 0)
        max = Vector4(bounds.max + s, 0)
        if is2D {
            max.z = 0
            min.z = 0
        }
    }
}
