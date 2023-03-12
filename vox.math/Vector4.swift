//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a 4D-vector.
public struct Vector4 {
    var elements: SIMD4<Float>

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

    public var z: Float {
        get {
            elements.z
        }
        set {
            elements.z = newValue
        }
    }

    public var w: Float {
        get {
            elements.w
        }
        set {
            elements.w = newValue
        }
    }
    
    public var xyz: Vector3 {
        Vector3(elements.xyz)
    }

    public var internalValue: SIMD4<Float> {
        get {
            elements
        }
    }

    public init() {
        elements = SIMD4<Float>(0, 0, 0, 0)
    }

    /// Constructor of Vector4.
    /// - Parameters:
    ///   - x: The x component of the vector, default 0
    ///   - y: The y component of the vector, default 0
    ///   - z: The z component of the vector, default 0
    ///   - w: The w component of the vector, default 0
    public init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, _ w: Float = 0) {
        elements = SIMD4<Float>(x, y, z, w)
    }

    public init(_ xyz: Vector3, _ w: Float) {
        elements = SIMD4<Float>(xyz.x, xyz.y, xyz.z, w)
    }

    /// Constructor of Vector4.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: SIMD4<Float>) {
        elements = array
    }
}

//MARK: - Static Methods

extension Vector4 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    public static func +(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(left.elements + right.elements)
    }

    public static func +=(left: inout Vector4, right: Vector4) {
        left.elements += right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    /// - Returns: The difference between two vectors
    public static func -(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(left.elements - right.elements)
    }

    public static func -=(left: inout Vector4, right: Vector4) {
        left.elements -= right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    public static func *(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(left.elements * right.elements)
    }

    public static func *=(left: inout Vector4, right: Vector4) {
        left.elements += right.elements
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    public static func *(left: Vector4, s: Float) -> Vector4 {
        Vector4(left.elements * s)
    }

    public static func *=(left: inout Vector4, right: Float) {
        left.elements += right
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    public static func /(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(left.elements / right.elements)
    }

    public static func /=(left: inout Vector4, right: Vector4) {
        left.elements /= right.elements
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    public static func /(left: Vector4, s: Float) -> Vector4 {
        Vector4(left.elements / s)
    }

    public static func /=(left: inout Vector4, right: Float) {
        left.elements /= right
    }

    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    /// - Returns: The vector facing in the opposite direction
    public static prefix func -(left: Vector4) -> Vector4 {
        Vector4(-left.elements)
    }
}

extension Vector4 {
    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    public static func dot(left: Vector4, right: Vector4) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    public static func distance(left: Vector4, right: Vector4) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    public static func distanceSquared(left: Vector4, right: Vector4) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    public static func equals(left: Vector4, right: Vector4) -> Bool {
        MathUtil.equals(left.x, right.x) &&
                MathUtil.equals(left.y, right.y) &&
                MathUtil.equals(left.z, right.z) &&
                MathUtil.equals(left.w, right.w)
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    /// - Returns: The result of linear blending between two vectors
    public static func lerp(left: Vector4, right: Vector4, t: Float) -> Vector4 {
        Vector4(mix(left.elements, right.elements, t: t))
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the largest components of the specified vectors
    public static func max(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(simd_max(left.elements, right.elements))
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the smallest components of the specified vectors
    public static func min(left: Vector4, right: Vector4) -> Vector4 {
        Vector4(simd_min(left.elements, right.elements))
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    /// - Returns: The normalized vector
    public static func normalize(left: Vector4) -> Vector4 {
        Vector4(simd_normalize(left.elements))
    }
}

//MARK: - Static Method: Transformation

extension Vector4 {
    /// Performs a transformation using the given 4x4 matrix.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - m: The transform matrix
    /// - Returns: The transformed vector4
    public static func transform(v: Vector4, m: Matrix) -> Vector4 {
        Vector4(simd_mul(m.elements, v.elements))
    }

    /// Performs a transformation using the given quaternion.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - q: The transform quaternion
    /// - Returns: The transformed vector
    public static func transformByQuat(v: Vector4, q: Quaternion) -> Vector4 {
        let x = v.x
        let y = v.y
        let z = v.z
        let w = v.w
        let qx = q.x
        let qy = q.y
        let qz = q.z
        let qw = q.w

        // calculate quat * vec
        let ix = qw * x + qy * z - qz * y
        let iy = qw * y + qz * x - qx * z
        let iz = qw * z + qx * y - qy * x
        let iw = -qx * x - qy * y - qz * z

        // calculate result * inverse quat
        return Vector4(ix * qw - iw * qx - iy * qz + iz * qy,
                iy * qw - iw * qy - iz * qx + ix * qz,
                iz * qw - iw * qz - ix * qy + iy * qx,
                w)
    }
}

//MARK: - Class Method

extension Vector4 {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    ///   - z: The z component of the vector
    ///   - w: The w component of the vector
    /// - Returns: This vector
    mutating func set(x: Float, y: Float, z: Float, w: Float) -> Vector4 {
        elements = SIMD4<Float>(x, y, z, w)
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    mutating func set(array: Array<Float>, offset: Int = 0) -> Vector4 {
        elements = SIMD4<Float>(array[offset],
                array[offset + 1],
                array[offset + 2],
                array[offset + 3])
        return self
    }

    /// Determines the sum of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func add(right: Vector4) -> Vector4 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func subtract(right: Vector4) -> Vector4 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func multiply(right: Vector4) -> Vector4 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func divide(right: Vector4) -> Vector4 {
        elements /= right.elements
        return self
    }

    /// Reverses the direction of this vector.
    /// - Returns: This vector
    public mutating func negate() -> Vector4 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    public mutating func normalize() -> Vector4 {
        if simd_length(elements) > Float.leastNonzeroMagnitude {
            elements = simd_normalize(elements)
        }
        return self
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    public mutating func scale(s: Float) -> Vector4 {
        elements *= s
        return self
    }
}

extension Vector4 {
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
        out[outOffset + 2] = z
        out[outOffset + 3] = w
    }
}

extension SIMD4<Float> {
    public var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

extension Vector4: Codable {
}
