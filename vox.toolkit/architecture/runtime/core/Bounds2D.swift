//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Internal bounds class.
final class Bounds2D {
    public var center: Vector2 = .zero
    var m_Size: Vector2 = .zero
    var m_Extents: Vector2 = .zero

    public var size: Vector2 {
        get {
            m_Size
        }

        set {
            m_Size = newValue

            m_Extents.x = m_Size.x * 0.5
            m_Extents.y = m_Size.y * 0.5
        }
    }

    public var extents: Vector2 {
        m_Extents
    }

    /// Returns an array of Vector2[] points for each corner, in the order right to left, top to bottom.
    public var corners: [Vector2] {
        [
            Vector2(center.x - extents.x, center.y + extents.y),
            Vector2(center.x + extents.x, center.y + extents.y),
            Vector2(center.x - extents.x, center.y - extents.y),
            Vector2(center.x + extents.x, center.y - extents.y),
        ]
    }

    public init() {}

    public init(center: Vector2, size: Vector2) {
        self.center = center
        self.size = size
    }

    /// Create bounds from a set of 2d points.
    public init(points: [Vector2]) {
        SetWithPoints(points)
    }

    /// Create bounds from a set of 2d points.
    public init(points: [Vector2], indexes: [Int]) {
        SetWithPoints(points, indexes: indexes)
    }

    /// Create bounds from a set of 3d points cast to 2d.
    internal init(points _: [Vector3], edges _: [Edge]) {}

    public init(points _: [Vector2], length _: Int) {}

    /// Returns true if the point is contained within the bounds.  False otherwise.
    public func ContainsPoint(_: Vector2) -> Bool {
        false
    }

    /// Returns true if any part of the line segment is contained within this bounding box.
    public func IntersectsLineSegment(from _: Vector2, to _: Vector2) -> Bool {
        false
    }

    /// Returns true if bounds overlap.
    public func Intersects(bounds _: Bounds2D) -> Bool {
        false
    }

    /// Check if this rect is intersected by another.
    /// - Parameter rect: rect
    /// - Returns: True if bounds overlaps rect.
    public func Intersects(rect _: Rect) -> Bool {
        false
    }

    /// Set this bounds center and size to encapsulate points.
    public func SetWithPoints(_: [Vector2]) {}

    /// Set this bounds center and size to encapsulate points.
    public func SetWithPoints(_: [Vector2], indexes _: [Int]) {}

    /// Returns the center of the bounding box of points. Optional parameter @length limits the bounds calculations
    /// to only the points up to length in array.
    public static func Center(points _: [Vector2]) -> Vector2 {
        Vector2()
    }

    public static func Center(points _: [Vector2], indexes _: [Int]) -> Vector2 {
        Vector2()
    }

    public static func Size(points _: [Vector2], indexes _: [Int]) -> Vector2 {
        Vector2()
    }

    internal static func Center(points _: [Vector4], indexes _: [Int]) -> Vector2 {
        Vector2()
    }
}

extension Bounds2D: CustomStringConvertible {
    var description: String {
        "[cen: \(center) size: \(size)]"
    }
}
