//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// A 2D Rectangle defined by X and Y position, width and height.
public struct Rect {
    private var m_XMin: Float
    private var m_YMin: Float
    private var m_Width: Float
    private var m_Height: Float

    /// Creates a new rectangle.
    /// - Parameters:
    ///   - x: The X value the rect is measured from.
    ///   - y: The Y value the rect is measured from.
    ///   - width: The width of the rectangle.
    ///   - height: The height of the rectangle.
    public init(x: Float, y: Float, width: Float, height: Float) {
        m_XMin = x
        m_YMin = y
        m_Width = width
        m_Height = height
    }

    /// Creates a rectangle given a size and position.
    /// - Parameters:
    ///   - position: The position of the minimum corner of the rect.
    ///   - size: The width and height of the rect.
    public init(position: Vector2, size: Vector2) {
        m_XMin = position.x
        m_YMin = position.y
        m_Width = size.x
        m_Height = size.y
    }

    /// <Shorthand for writing new Rect(0,0,0,0).
    public static let zero: Rect = Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)

    /// Creates a rectangle from min/max coordinate values.
    /// - Parameters:
    ///   - xmin: The minimum X coordinate.
    ///   - ymin: The minimum Y coordinate.
    ///   - xmax: The maximum X coordinate.
    ///   - ymax: The maximum Y coordinate.
    /// - Returns: A rectangle matching the specified coordinates.
    public static func minMaxRect(xmin: Float, ymin: Float, xmax: Float, ymax: Float) -> Rect {
        Rect(x: xmin, y: ymin, width: xmax - xmin, height: ymax - ymin)
    }

    /// Set components of an existing Rect.
    public mutating func set(x: Float, y: Float, width: Float, height: Float) {
        m_XMin = x
        m_YMin = y
        m_Width = width
        m_Height = height
    }

    /// The X coordinate of the rectangle.
    public var x: Float {
        get {
            m_XMin
        }
        set {
            m_XMin = newValue
        }
    }

    /// The Y coordinate of the rectangle.
    public var y: Float {
        get {
            m_YMin
        }
        set {
            m_YMin = newValue
        }
    }

    /// The X and Y position of the rectangle.
    public var position: Vector2 {
        get {
            Vector2(m_XMin, m_YMin)
        }
        set {
            m_XMin = newValue.x
            m_YMin = newValue.y
        }
    }

    /// The position of the center of the rectangle.
    public var center: Vector2 {
        get {
            Vector2(x + m_Width / 2, y + m_Height / 2)
        }
        set {
            m_XMin = newValue.x - m_Width / 2
            m_YMin = newValue.y - m_Height / 2
        }
    }

    /// The position of the minimum corner of the rectangle.
    public var min: Vector2 {
        get {
            Vector2(xMin, yMin)
        }
        set {
            xMin = newValue.x
            yMin = newValue.y
        }
    }

    /// The position of the maximum corner of the rectangle.
    public var max: Vector2 {
        get {
            Vector2(xMax, yMax)
        }
        set {
            xMax = newValue.x
            yMax = newValue.y
        }
    }

    /// The width of the rectangle, measured from the X position.
    public var width: Float {
        get {
            m_Width
        }
        set {
            m_Width = newValue
        }
    }

    /// The height of the rectangle, measured from the Y position.
    public var height: Float {
        get {
            m_Height
        }
        set {
            m_Height = newValue
        }
    }

    /// The width and height of the rectangle.
    public var size: Vector2 {
        get {
            Vector2(m_Width, m_Height)
        }
        set {
            m_Width = newValue.x
            m_Height = newValue.y
        }
    }

    /// The minimum X coordinate of the rectangle.
    public var xMin: Float {
        get {
            m_XMin
        }
        set {
            m_XMin = newValue
            m_Width = xMax - m_XMin
        }
    }

    /// The minimum Y coordinate of the rectangle.
    public var yMin: Float {
        get {
            m_YMin
        }
        set {
            m_YMin = newValue
            m_Height = yMax - m_YMin
        }
    }

    /// The maximum X coordinate of the rectangle.
    public var xMax: Float {
        get {
            m_Width + m_XMin
        }
        set {
            m_Width = newValue - m_XMin
        }
    }

    /// The maximum Y coordinate of the rectangle.
    public var yMax: Float {
        get {
            m_Height + m_YMin
        }
        set {
            m_Height = newValue - m_YMin
        }
    }

    /// Returns true if the x and y components of point is a point inside this rectangle.
    /// If allowInverse is present and true, the width and height of the Rect are allowed to take negative values
    /// (ie, the min value is greater than the max), and the test will still work.
    /// - Parameter point: Point to test.
    /// - Returns: True if the point lies within the specified rectangle.
    public func Contains(point: Vector2) -> Bool {
        point.x >= xMin && point.x < xMax && point.y >= yMin && point.y < yMax
    }

    /// Returns true if the x and y components of point is a point inside this rectangle.
    /// If allowInverse is present and true, the width and height of the Rect are allowed to take negative values
    /// (ie, the min value is greater than the max), and the test will still work.
    /// - Parameter point: Point to test.
    /// - Returns: True if the point lies within the specified rectangle.
    public func Contains(point: Vector3) -> Bool {
        point.x >= xMin && point.x < xMax && point.y >= yMin && point.y < yMax
    }

    /// Returns true if the x and y components of point is a point inside this rectangle.
    /// If allowInverse is present and true, the width and height of the Rect are allowed to take negative values
    /// (ie, the min value is greater than the max), and the test will still work.
    /// - Parameters:
    ///   - point: Point to test.
    ///   - allowInverse: Does the test allow the Rect's width and height to be negative?
    /// - Returns: True if the point lies within the specified rectangle.
    public func Contains( point:Vector3,  allowInverse:Bool) -> Bool {
        !allowInverse ? Contains(point: point) :
        (width < 0.0 && point.x <= xMin && point.x > xMax || width >= 0.0 && point.x >= xMin && point.x < xMax)
        && (height < 0.0 && point.y <= yMin && point.y > yMax || height >= 0.0 && point.y >= yMin && point.y < yMax)
    }

    private static func OrderMinMax(rect: Rect) -> Rect {
        var rect = rect
        if (rect.xMin > rect.xMax) {
            let xMin = rect.xMin
            rect.xMin = rect.xMax
            rect.xMax = xMin
        }
        if (rect.yMin > rect.yMax) {
            let yMin = rect.yMin
            rect.yMin = rect.yMax
            rect.yMax = yMin
        }
        return rect
    }

    /// Returns true if the other rectangle overlaps this one.
    /// If allowInverse is present and true, the widths and heights of the Rects are allowed to take negative values
    /// (ie, the min value is greater than the max), and the test will still work.
    /// - Parameter other: Other rectangle to test overlapping with.
    /// - Returns: Overlaps
    public func Overlaps(other: Rect) -> Bool {
        other.xMax > xMin && other.xMin < xMax && other.yMax > yMin && other.yMin < yMax
    }

    /// Returns true if the other rectangle overlaps this one. If allowInverse is present and true,
    /// the widths and heights of the Rects are allowed to take negative values (ie, the min value is greater than the max), and the test will still work.
    /// - Parameters:
    ///   - other: Other rectangle to test overlapping with.
    ///   - allowInverse: Does the test allow the widths and heights of the Rects to be negative?
    /// - Returns: Overlaps
    public mutating func Overlaps(other: Rect, allowInverse: Bool) -> Bool {
        var other = other
        if (allowInverse) {
            self = Rect.OrderMinMax(rect: self)
            other = Rect.OrderMinMax(rect: other)
        }
        return self.Overlaps(other: other)
    }
    
    /// Returns a point inside a rectangle, given normalized coordinates.
    /// - Parameters:
    ///   - rectangle: Rectangle to get a point inside.
    ///   - normalizedRectCoordinates: Normalized coordinates to get a point for.
    /// - Returns: NormalizedToPoint
    public static func NormalizedToPoint(rectangle: Rect, normalizedRectCoordinates: Vector2) -> Vector2 {
        Vector2(MathUtil.lerp(a: rectangle.x, b: rectangle.xMax, t: normalizedRectCoordinates.x),
                MathUtil.lerp(a: rectangle.y, b: rectangle.yMax, t: normalizedRectCoordinates.y))
    }

    /// Returns the normalized coordinates cooresponding the the point.
    /// - Parameters:
    ///   - rectangle: Rectangle to get normalized coordinates inside.
    ///   - point: A point inside the rectangle to get normalized coordinates for.
    /// - Returns: PointToNormalized
    public static func PointToNormalized(rectangle: Rect, point: Vector2) -> Vector2 {
        Vector2(MathUtil.inverseLerp(a: rectangle.x, b: rectangle.xMax, value: point.x),
                MathUtil.inverseLerp(a: rectangle.y, b: rectangle.yMax, value: point.y))
    }
}

extension Rect: Codable {
}
