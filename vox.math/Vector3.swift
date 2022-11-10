//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a 3D-vector.
struct Vector3 {
    /// An array containing the elements of the vector
    var elements: SIMD3<Float>

    var x: Float {
        get {
            elements.x
        }
    }

    var y: Float {
        get {
            elements.y
        }
    }

    var z: Float {
        get {
            elements.z
        }
    }

    init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0) {
        elements = SIMD3<Float>(x, y, z)
    }

    /// Constructor of Vector3.
    /// - Parameters:
    ///   - array: The component of the vector
    init(_ array: SIMD3<Float>) {
        elements = array
    }
}

//MARK:- Static Methods

extension Vector3 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    static func +(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements + right.elements)
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    /// - Returns: The difference between two vectors
    static func -(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements - right.elements)
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    static func *(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements * right.elements)
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    static func *(left: Vector3, s: Float) -> Vector3 {
        Vector3(left.elements * s)
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    static func /(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements / right.elements)
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    static func /(left: Vector3, right: Float) -> Vector3 {
        Vector3(left.elements / right)
    }

    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    /// - Returns: The vector facing in the opposite direction
    static prefix func -(left: Vector3) -> Vector3 {
        Vector3(-left.elements)
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    static func dot(left: Vector3, right: Vector3) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the cross product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to cross
    ///   - right: The second vector to cross
    /// - Returns: The cross product of two vectors
    static func cross(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_cross(left.elements, right.elements))
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    static func distance(left: Vector3, right: Vector3) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    static func distanceSquared(left: Vector3, right: Vector3) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    static func equals(left: Vector3, right: Vector3) -> Bool {
        MathUtil.equals(left.x, right.x) && MathUtil.equals(left.y, right.y) && MathUtil.equals(left.z, right.z)
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    /// - Returns: The result of linear blending between two vectors
    static func lerp(left: Vector3, right: Vector3, t: Float) -> Vector3 {
        Vector3(mix(left.elements, right.elements, t: t));
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the largest components of the specified vectors
    static func max(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_max(left.elements, right.elements))
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the smallest components of the specified vectors
    static func min(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_min(left.elements, right.elements))
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    /// - Returns: The normalized vector
    static func normalize(left: Vector3) -> Vector3 {
        Vector3(simd_normalize(left.elements))
    }
}

//MARK:- Static Method: Transformation

extension Vector3 {
    /// Performs a normal transformation using the given 4x4 matrix.
    /// - Remark: A normal transform performs the transformation with the assumption that the w component
    /// is zero. This causes the fourth row and fourth column of the matrix to be unused. The
    /// end result is a vector that is not translated, but all other transformation properties
    /// apply. This is often preferred for normal vectors as normals purely represent direction
    /// rather than location because normal vectors should not be translated.
    /// - Parameters:
    ///   - v: The normal vector to transform
    ///   - m: The transform matrix
    /// - Returns: The transformed normal
    static func transformNormal(v: Vector3, m: Matrix) -> Vector3 {
        let x = v.x
        let y = v.y
        let z = v.z
        return Vector3(x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + z * m.elements.columns.2[0],
                x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + z * m.elements.columns.2[1],
                x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + z * m.elements.columns.2[2])
    }

    /// Performs a transformation using the given 4x4 matrix.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - m: The transform matrix
    /// - Returns:The transformed vector3
    static func transformToVec3(v: Vector3, m: Matrix) -> Vector3 {
        let x = v.x
        let y = v.y
        let z = v.z

        return Vector3(x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + z * m.elements.columns.2[0] + m.elements.columns.3[0],
                x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + z * m.elements.columns.2[1] + m.elements.columns.3[1],
                x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + z * m.elements.columns.2[2] + m.elements.columns.3[2])
    }

    /// Performs a transformation from vector3 to vector4 using the given 4x4 matrix.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - m: The transform matrix
    /// - Returns: The transformed vector4
    static func transformToVec4(v: Vector3, m: Matrix) -> Vector4 {
        let x = v.x
        let y = v.y
        let z = v.z

        return Vector4(x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + z * m.elements.columns.2[0] + m.elements.columns.3[0],
                x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + z * m.elements.columns.2[1] + m.elements.columns.3[0],
                x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + z * m.elements.columns.2[2] + m.elements.columns.3[0],
                x * m.elements.columns.0[3] + y * m.elements.columns.1[3] + z * m.elements.columns.2[3] + m.elements.columns.3[0])
    }

    /// Performs a coordinate transformation using the given 4x4 matrix.
    /// - Remark:
    /// A coordinate transform performs the transformation with the assumption that the w component
    /// is one. The four dimensional vector obtained from the transformation operation has each
    /// component in the vector divided by the w component. This forces the w-component to be one and
    /// therefore makes the vector homogeneous. The homogeneous vector is often preferred when working
    /// with coordinates as the w component can safely be ignored.
    /// - Parameters:
    ///   - v: The coordinate vector to transform
    ///   - m: The transform matrix
    /// - Returns: The transformed coordinates
    static func transformCoordinate(v: Vector3, m: Matrix) -> Vector3 {
        let x = v.x
        let y = v.y
        let z = v.z
        var w = x * m.elements.columns.0[3] + y * m.elements.columns.1[3] + z * m.elements.columns.2[3] + m.elements.columns.3[3]
        w = 1.0 / w

        return Vector3((x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + z * m.elements.columns.2[0] + m.elements.columns.3[0]) * w,
                (x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + z * m.elements.columns.2[1] + m.elements.columns.3[1]) * w,
                (x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + z * m.elements.columns.2[2] + m.elements.columns.3[2]) * w)
    }

    /// Performs a transformation using the given quaternion.
    /// - Parameters:
    ///   - v: The vector to transform
    ///   - quaternion: The transform quaternion
    /// - Returns: The transformed vector
    static func transformByQuat(v: Vector3, quaternion: Quaternion) -> Vector3 {
        let x = v.x
        let y = v.y
        let z = v.z
        let qx = quaternion.x
        let qy = quaternion.y
        let qz = quaternion.z
        let qw = quaternion.w

        // calculate quat * vec
        let ix = qw * x + qy * z - qz * y
        let iy = qw * y + qz * x - qx * z
        let iz = qw * z + qx * y - qy * x
        let iw = -qx * x - qy * y - qz * z

        // calculate result * inverse quat
        return Vector3(ix * qw - iw * qx - iy * qz + iz * qy,
                iy * qw - iw * qy - iz * qx + ix * qz,
                iz * qw - iw * qz - ix * qy + iy * qx)
    }
}

//MARK:- Class Method

extension Vector3 {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    ///   - z: The z component of the vector
    /// - Returns: This vector
    mutating func set(x: Float, y: Float, z: Float) -> Vector3 {
        elements = SIMD3<Float>(x, y, z)
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    mutating func set(array: Array<Float>, offset: Int = 0) -> Vector3 {
        elements = SIMD3<Float>(array[offset],
                array[offset + 1],
                array[offset + 2])
        return self
    }

    /// Determines the sum of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    mutating func add(right: Vector3) -> Vector3 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    mutating func subtract(right: Vector3) -> Vector3 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    mutating func multiply(right: Vector3) -> Vector3 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    mutating func divide(right: Vector3) -> Vector3 {
        elements /= right.elements
        return self
    }


    /// Reverses the direction of this vector.
    /// - Returns: This vector
    mutating func negate() -> Vector3 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    mutating func normalize() -> Vector3 {
        elements = simd_normalize(elements)
        return self
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    mutating func scale(s: Float) -> Vector3 {
        elements *= s
        return self
    }

    /// Calculate the length of this vector.
    /// - Returns: The length of this vector
    func length() -> Float {
        simd_length(elements)
    }

    /// Calculate the squared length of this vector.
    /// - Returns: The squared length of this vector
    func lengthSquared() -> Float {
        simd_length_squared(elements)
    }

    /// Clone the value of this vector to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = x
        out[outOffset + 1] = y
        out[outOffset + 2] = z
    }
}

extension Vector3 {
    /// This vector performs a normal transformation using the given 4x4 matrix.
    /// - Remark:
    /// A normal transform performs the transformation with the assumption that the w component
    /// is zero. This causes the fourth row and fourth column of the matrix to be unused. The
    /// end result is a vector that is not translated, but all other transformation properties
    /// apply. This is often preferred for normal vectors as normals purely represent direction
    /// rather than location because normal vectors should not be translated.
    /// - Parameter m: The transform matrix
    /// - Returns: This vector
    mutating func transformNormal(m: Matrix) -> Vector3 {
        self = Vector3.transformNormal(v: self, m: m)
        return self
    }

    /// This vector performs a transformation using the given 4x4 matrix.
    /// - Parameter m: The transform matrix
    /// - Returns: This vector
    mutating func transformToVec3(m: Matrix) -> Vector3 {
        self = Vector3.transformToVec3(v: self, m: m)
        return self
    }

    /// This vector performs a coordinate transformation using the given 4x4 matrix.
    /// - Remark:
    /// A coordinate transform performs the transformation with the assumption that the w component
    /// is one. The four dimensional vector obtained from the transformation operation has each
    /// component in the vector divided by the w component. This forces the w-component to be one and
    /// therefore makes the vector homogeneous. The homogeneous vector is often preferred when working
    /// with coordinates as the w component can safely be ignored.
    /// - Parameter m: The transform matrix
    /// - Returns: This vector
    mutating func transformCoordinate(m: Matrix) -> Vector3 {
        self = Vector3.transformCoordinate(v: self, m: m)
        return self
    }

    /// This vector performs a transformation using the given quaternion.
    /// - Parameter quaternion: The transform quaternion
    /// - Returns: This vector
    mutating func transformByQuat(quaternion: Quaternion) -> Vector3 {
        self = Vector3.transformByQuat(v: self, quaternion: quaternion)
        return self
    }
}
