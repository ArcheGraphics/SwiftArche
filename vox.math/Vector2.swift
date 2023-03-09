//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a 2D-vector.
public struct Vector2 {
    public static let zero = Vector2(0.0, 0.0)
    public static let one = Vector2(1, 1)
    public static let up = Vector2(0.0, 1)
    public static let down = Vector2(0.0, -1)
    public static let left = Vector2(-1, 0.0)
    public static let right = Vector2(1, 0.0)
    public static let positiveInfinity = Vector2(Float.infinity, Float.infinity)
    public static let negativeInfinity = Vector2(-Float.infinity, -Float.infinity)

    /// An array containing the elements of the vector
    var elements: SIMD2<Float>

    public var x: Float {
        get {
            elements.x
        }
        set {
            elements.x = newValue
        }
    }

    public var y: Float {
        get {
            elements.y
        }
        set {
            elements.y = newValue
        }
    }

    public var internalValue: SIMD2<Float> {
        get {
            elements
        }
    }

    public init() {
        elements = SIMD2<Float>(0, 0)
    }

    /// Constructor of Vector2.
    /// - Parameters:
    ///   - x: The x component of the vector, default 0
    ///   - y: The y component of the vector, default 0
    public init(_ x: Float = 0, _ y: Float = 0) {
        elements = SIMD2<Float>(x, y)
    }

    /// Constructor of Vector2.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: SIMD2<Float>) {
        elements = array
    }
}

//MARK: - Static Methods

extension Vector2 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    public static func +(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(left.elements + right.elements)
    }

    public static func +=(left: inout Vector2, right: Vector2) {
        left.elements += right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    /// - Returns: The difference between two vectors
    public static func -(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(left.elements - right.elements)
    }

    public static func -=(left: inout Vector2, right: Vector2) {
        left.elements -= right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    public static func *(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(left.elements * right.elements)
    }

    public static func *=(left: inout Vector2, right: Vector2) {
        left.elements *= right.elements
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    public static func *(left: Vector2, s: Float) -> Vector2 {
        Vector2(left.elements * s)
    }

    public static func *=(left: inout Vector2, right: Float) {
        left.elements *= right
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    public static func /(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(left.elements / right.elements)
    }

    public static func /=(left: inout Vector2, right: Vector2) {
        left.elements /= right.elements
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    public static func /(left: Vector2, right: Float) -> Vector2 {
        Vector2(left.elements / right)
    }

    public static func /=(left: inout Vector2, right: Float) {
        left.elements /= right
    }
}

extension Vector2 {
    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    /// - Returns: The vector facing in the opposite direction
    public static prefix func -(left: Vector2) -> Vector2 {
        Vector2(-left.elements)
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    public static func dot(left: Vector2, right: Vector2) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    public static func distance(left: Vector2, right: Vector2) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    public static func distanceSquared(left: Vector2, right: Vector2) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    public static func equals(left: Vector2, right: Vector2) -> Bool {
        MathUtil.equals(left.x, right.x) && MathUtil.equals(left.y, right.y)
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    /// - Returns: The result of linear blending between two vectors
    public static func lerp(left: Vector2, right: Vector2, t: Float) -> Vector2 {
        Vector2(mix(left.elements, right.elements, t: t))
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the largest components of the specified vectors
    public static func max(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(simd_max(left.elements, right.elements))
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the smallest components of the specified vectors
    public static func min(left: Vector2, right: Vector2) -> Vector2 {
        Vector2(simd_min(left.elements, right.elements))
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    /// - Returns: The normalized vector
    public static func normalize(left: Vector2) -> Vector2 {
        Vector2(simd_normalize(left.elements))
    }
}

//MARK: - Class Method

extension Vector2 {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    /// - Returns: This vector
    mutating func set(x: Float, y: Float) -> Vector2 {
        elements = SIMD2<Float>(x, y)
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    mutating func set(array: Array<Float>, offset: Int = 0) -> Vector2 {
        elements = SIMD2<Float>(array[offset], array[offset + 1])
        return self
    }

    /// Determines the sum of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func add(right: Vector2) -> Vector2 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func subtract(right: Vector2) -> Vector2 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func multiply(right: Vector2) -> Vector2 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func divide(right: Vector2) -> Vector2 {
        elements /= right.elements
        return self
    }

    /// Reverses the direction of this vector.
    /// - Returns: This vector
    public mutating func negate() -> Vector2 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    public mutating func normalize() -> Vector2 {
        if simd_length(elements) > Float.leastNonzeroMagnitude {
            elements = simd_normalize(elements)
        }
        return self
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    public mutating func scale(s: Float) -> Vector2 {
        elements *= s
        return self
    }
}

extension Vector2 {
    /// Calculate the length of this vector.
    /// - Returns: The length of this vector
    public func length() -> Float {
        simd_length(elements)
    }

    /// Calculate the squared length of this vector.
    /// - Returns: The squared length of this vector
    public func lengthSquared() -> Float {
        simd_length_squared(elements)
    }

    /// Clone the value of this vector to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    public func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = x
        out[outOffset + 1] = y
    }
}

extension Vector2: Codable {
}
