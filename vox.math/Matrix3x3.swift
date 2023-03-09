//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Represents a 3x3 mathematical matrix.
public struct Matrix3x3 {
    public var elements: simd_float3x3
    
    enum CodingKeys: String, CodingKey {
        case m11; case m12; case m13
        case m21; case m22; case m23
        case m31; case m32; case m33
    }

    /// Constructor of 3*3 matrix.
    /// - Parameters:
    ///   - m11: Default 1 column 1, row 1
    ///   - m12: Default 0 column 1, row 2
    ///   - m13: Default 0 column 1, row 3
    ///   - m21: Default 0 column 2, row 1
    ///   - m22: Default 1 column 2, row 2
    ///   - m23: Default 0 column 2, row 3
    ///   - m31: Default 0 column 3, row 1
    ///   - m32: Default 0 column 3, row 2
    ///   - m33: Default 1 column 3, row 3
    public init(m11: Float = 1, m12: Float = 0, m13: Float = 0,
                m21: Float = 0, m22: Float = 1, m23: Float = 0,
                m31: Float = 0, m32: Float = 0, m33: Float = 1) {
        elements = simd_float3x3([SIMD3<Float>(m11, m12, m13),
                                  SIMD3<Float>(m21, m22, m23),
                                  SIMD3<Float>(m31, m32, m33)])
    }

    /// Constructor of Vector3.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: simd_float3x3) {
        elements = array
    }

    public init(_ matrix: Matrix) {
        elements = simd_float3x3([SIMD3<Float>(matrix.elements.columns.0[0], matrix.elements.columns.0[1], matrix.elements.columns.0[2]),
                                  SIMD3<Float>(matrix.elements.columns.1[0], matrix.elements.columns.1[1], matrix.elements.columns.1[2]),
                                  SIMD3<Float>(matrix.elements.columns.2[0], matrix.elements.columns.2[1], matrix.elements.columns.2[2]), ])
    }
}

//MARK: - Static Methods

extension Matrix3x3 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    public static func +(left: Matrix3x3, right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3(left.elements + right.elements)
    }

    public static func +=(left: inout Matrix3x3, right: Matrix3x3) {
        left.elements += right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    /// - Returns: The difference between two vectors
    public static func -(left: Matrix3x3, right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3(left.elements - right.elements)
    }

    public static func -=(left: inout Matrix3x3, right: Matrix3x3) {
        left.elements -= right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    public static func *(left: Matrix3x3, right: Matrix3x3) -> Matrix3x3 {
        Matrix3x3(left.elements * right.elements)
    }

    public static func *=(left: inout Matrix3x3, right: Matrix3x3) {
        left.elements *= right.elements
    }
}

extension Matrix3x3 {
    /// Determines whether the specified matrices are equals.
    /// - Parameters:
    ///   - left: The first matrix to compare
    ///   - right: The second matrix to compare
    /// - Returns: True if the specified matrices are equals, false otherwise
    public static func equals(left: Matrix3x3, right: Matrix3x3) -> Bool {
        MathUtil.equals(left.elements.columns.0[0], right.elements.columns.0[0]) &&
                MathUtil.equals(left.elements.columns.0[1], right.elements.columns.0[1]) &&
                MathUtil.equals(left.elements.columns.0[2], right.elements.columns.0[2]) &&
                MathUtil.equals(left.elements.columns.1[0], right.elements.columns.1[0]) &&
                MathUtil.equals(left.elements.columns.1[1], right.elements.columns.1[1]) &&
                MathUtil.equals(left.elements.columns.1[2], right.elements.columns.1[2]) &&
                MathUtil.equals(left.elements.columns.2[0], right.elements.columns.2[0]) &&
                MathUtil.equals(left.elements.columns.2[1], right.elements.columns.2[1]) &&
                MathUtil.equals(left.elements.columns.2[2], right.elements.columns.2[2])
    }

    /// Performs a linear interpolation between two matrices.
    /// - Parameters:
    ///   - start: The first matrix
    ///   - end: The second matrix
    ///   - t: The blend amount where 0 returns start and 1 end
    /// - Returns: The result of linear blending between two matrices
    public static func lerp(start: Matrix3x3, end: Matrix3x3, t: Float) -> Matrix3x3 {
        Matrix3x3(simd_linear_combination(1 - t, start.elements, t, end.elements))
    }

    /// Calculate a rotation matrix from a quaternion.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    /// - Returns: The calculated rotation matrix
    public static func rotationQuaternion(quaternion: Quaternion) -> Matrix3x3 {
        Matrix3x3(matrix_float3x3(quaternion.elements))
    }

    /// Calculate a matrix from scale vector.
    /// - Parameters:
    ///   - s: The scale vector
    /// - Returns: The calculated matrix
    public static func scaling(s: Vector2) -> Matrix3x3 {
        Matrix3x3(matrix_float3x3(diagonal: SIMD3<Float>(s.x, s.y, 1)))
    }

    /// Calculate a matrix from translation vector.
    /// - Parameters:
    ///   - translation: The translation vector
    /// - Returns: The calculated matrix
    public static func translation(translation: Vector2) -> Matrix3x3 {
        var elements = matrix_float3x3(diagonal: SIMD3<Float>(1, 1, 1))
        elements.columns.2[0] = translation.x
        elements.columns.2[1] = translation.y
        return Matrix3x3(elements)
    }


    /// Calculate the inverse of the specified matrix.
    /// - Parameters:
    ///   - a: The matrix whose inverse is to be calculated
    /// - Returns: The inverse of the specified matrix
    public static func invert(a: Matrix3x3) -> Matrix3x3 {
        Matrix3x3(a.elements.inverse)
    }

    /// Calculate a 3x3 normal matrix from a 4x4 matrix.
    /// - Remark:
    /// The calculation process is the transpose matrix of the inverse matrix.
    /// - Parameters:
    ///   - mat4: The 4x4 matrix
    /// - Returns: The 3x3 normal matrix
    public static func normalMatrix(mat4: Matrix) -> Matrix3x3 {
        let a11 = mat4.elements.columns.0[0]
        let a12 = mat4.elements.columns.0[1]
        let a13 = mat4.elements.columns.0[2]
        let a14 = mat4.elements.columns.0[3]
        let a21 = mat4.elements.columns.1[0]
        let a22 = mat4.elements.columns.1[1]
        let a23 = mat4.elements.columns.1[2]
        let a24 = mat4.elements.columns.1[3]
        let a31 = mat4.elements.columns.2[0]
        let a32 = mat4.elements.columns.2[1]
        let a33 = mat4.elements.columns.2[2]
        let a34 = mat4.elements.columns.2[3]
        let a41 = mat4.elements.columns.3[0]
        let a42 = mat4.elements.columns.3[1]
        let a43 = mat4.elements.columns.3[2]
        let a44 = mat4.elements.columns.3[3]

        let b00 = a11 * a22 - a12 * a21
        let b01 = a11 * a23 - a13 * a21
        let b02 = a11 * a24 - a14 * a21
        let b03 = a12 * a23 - a13 * a22
        let b04 = a12 * a24 - a14 * a22
        let b05 = a13 * a24 - a14 * a23
        let b06 = a31 * a42 - a32 * a41
        let b07 = a31 * a43 - a33 * a41
        let b08 = a31 * a44 - a34 * a41
        let b09 = a32 * a43 - a33 * a42
        let b10 = a32 * a44 - a34 * a42
        let b11 = a33 * a44 - a34 * a43

        var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06
        if (det == 0) {
            return Matrix3x3()
        }
        det = 1.0 / det

        return Matrix3x3(m11: (a22 * b11 - a23 * b10 + a24 * b09) * det,
                m12: (a23 * b08 - a21 * b11 - a24 * b07) * det,
                m13: (a21 * b10 - a22 * b08 + a24 * b06) * det,

                m21: (a13 * b10 - a12 * b11 - a14 * b09) * det,
                m22: (a11 * b11 - a13 * b08 + a14 * b07) * det,
                m23: (a12 * b08 - a11 * b10 - a14 * b06) * det,

                m31: (a42 * b05 - a43 * b04 + a44 * b03) * det,
                m32: (a43 * b02 - a41 * b05 - a44 * b01) * det,
                m33: (a41 * b04 - a42 * b02 + a44 * b00) * det)
    }

    /// The specified matrix rotates around an angle.
    /// - Parameters:
    ///   - a: The specified matrix
    ///   - r: The rotation angle in radians
    /// - Returns: The rotated matrix
    public static func rotate(a: Matrix3x3, r: Float) -> Matrix3x3 {
        let s = sin(r)
        let c = cos(r)

        let a11 = a.elements.columns.0[0]
        let a12 = a.elements.columns.0[1]
        let a13 = a.elements.columns.0[2]
        let a21 = a.elements.columns.1[0]
        let a22 = a.elements.columns.1[1]
        let a23 = a.elements.columns.1[2]
        let a31 = a.elements.columns.2[0]
        let a32 = a.elements.columns.2[1]
        let a33 = a.elements.columns.2[2]

        return Matrix3x3(m11: c * a11 + s * a21,
                m12: c * a12 + s * a22,
                m13: c * a13 + s * a23,

                m21: c * a21 - s * a11,
                m22: c * a22 - s * a12,
                m23: c * a23 - s * a13,

                m31: a31,
                m32: a32,
                m33: a33)
    }

    /// Scale a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - s: The given vector
    /// - Returns: The scaled matrix
    public static func scale(m: Matrix3x3, s: Vector2) -> Matrix3x3 {
        var elements = m.elements
        elements.columns.0 *= s.x
        elements.columns.1 *= s.y
        return Matrix3x3(elements)
    }

    /// Translate a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - translation: The given vector
    /// - Returns: The translated matrix
    public static func translate(m: Matrix3x3, translation: Vector2) -> Matrix3x3 {
        let x = translation.x
        let y = translation.y
        var elements = m.elements

        elements.columns.2[0] = x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + m.elements.columns.2[0]
        elements.columns.2[1] = x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + m.elements.columns.2[1]
        elements.columns.2[2] = x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + m.elements.columns.2[2]
        return Matrix3x3(elements)
    }

    /// Calculate the transpose of the specified matrix.
    /// - Parameters:
    ///   - a: The specified matrix
    /// - Returns: The transpose of the specified matrix
    public static func transpose(a: Matrix3x3) -> Matrix3x3 {
        Matrix3x3(a.elements.transpose)
    }
}

//MARK: - Class Method

extension Matrix3x3 {
    /// Set the value of this matrix, and return this matrix.
    mutating func set(m11: Float, m12: Float, m13: Float,
                             m21: Float, m22: Float, m23: Float,
                             m31: Float, m32: Float, m33: Float
    ) -> Matrix3x3 {
        elements.columns.0 = SIMD3<Float>(m11, m12, m13)
        elements.columns.1 = SIMD3<Float>(m21, m22, m23)
        elements.columns.2 = SIMD3<Float>(m31, m32, m33)

        return self
    }

    /// Set the value of this matrix by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This matrix
    mutating func set(array: Array<Float>, offset: Int = 0) -> Matrix3x3 {
        var index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                elements[i, j] = array[index + offset]
                index += 1
            }
        }
        return self
    }

    /// Set the value of this 3x3 matrix by the specified 4x4 matrix.
    /// - Remark: upper-left principle
    /// - Parameter a: The specified 4x4 matrix
    /// - Returns: This 3x3 matrix
    mutating func set(a: Matrix) -> Matrix3x3 {
        elements.columns.0[0] = a.elements.columns.0[0]
        elements.columns.0[1] = a.elements.columns.0[1]
        elements.columns.0[2] = a.elements.columns.0[2]

        elements.columns.1[0] = a.elements.columns.1[0]
        elements.columns.1[1] = a.elements.columns.1[1]
        elements.columns.1[2] = a.elements.columns.1[2]

        elements.columns.2[0] = a.elements.columns.2[0]
        elements.columns.2[1] = a.elements.columns.2[1]
        elements.columns.2[2] = a.elements.columns.2[2]

        return self
    }

    /// Determines the sum of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the sum of the two matrices
    public mutating func add(right: Matrix3x3) -> Matrix3x3 {
        self = self + right
        return self
    }

    /// Determines the difference between this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the difference between the two matrices
    public mutating func subtract(right: Matrix3x3) -> Matrix3x3 {
        self = self - right
        return self
    }

    /// Determines the product of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the product of the two matrices
    public mutating func multiply(right: Matrix3x3) -> Matrix3x3 {
        self = self * right
        return self
    }

    /// Identity this matrix.
    /// - Returns: This matrix after identity
    public mutating func identity() -> Matrix3x3 {
        elements = simd_float3x3(diagonal: SIMD3<Float>(1, 1, 1))
        return self
    }

    /// Invert the matrix.
    /// - Returns: The matrix after invert
    public mutating func invert() -> Matrix3x3 {
        self = Matrix3x3.invert(a: self)
        return self
    }


    /// This matrix rotates around an angle.
    /// - Parameter r: The rotation angle in radians
    /// - Returns: This matrix after rotate
    public mutating func rotate(r: Float) -> Matrix3x3 {
        self = Matrix3x3.rotate(a: self, r: r)
        return self
    }

    /// Scale this matrix by a given vector.
    /// - Parameter s: The given vector
    /// - Returns: This matrix after scale
    public mutating func scale(s: Vector2) -> Matrix3x3 {
        self = Matrix3x3.scale(m: self, s: s)
        return self
    }

    /// Translate this matrix by a given vector.
    /// - Parameter translation: The given vector
    /// - Returns: This matrix after translate
    public mutating func translate(translation: Vector2) -> Matrix3x3 {
        self = Matrix3x3.translate(m: self, translation: translation)
        return self
    }

    /// Calculate the transpose of this matrix.
    /// - Returns: This matrix after transpose
    public mutating func transpose() -> Matrix3x3 {
        self = Matrix3x3.transpose(a: self)
        return self
    }
}

extension Matrix3x3 {
    /// Clone the value of this matrix to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    public func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = elements.columns.0[0]
        out[outOffset + 1] = elements.columns.0[1]
        out[outOffset + 2] = elements.columns.0[2]
        out[outOffset + 3] = elements.columns.1[0]
        out[outOffset + 4] = elements.columns.1[1]
        out[outOffset + 5] = elements.columns.1[2]
        out[outOffset + 6] = elements.columns.2[0]
        out[outOffset + 7] = elements.columns.2[1]
        out[outOffset + 8] = elements.columns.2[2]
    }

    /// Calculate a determinant of this matrix.
    /// - Returns: The determinant of this matrix
    public func determinant() -> Float {
        elements.determinant
    }
}

extension Matrix3x3: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(elements.columns.0[0], forKey: .m11)
        try container.encode(elements.columns.0[1], forKey: .m12)
        try container.encode(elements.columns.0[2], forKey: .m13)
        
        try container.encode(elements.columns.1[0], forKey: .m21)
        try container.encode(elements.columns.1[1], forKey: .m22)
        try container.encode(elements.columns.1[2], forKey: .m23)
        
        try container.encode(elements.columns.2[0], forKey: .m31)
        try container.encode(elements.columns.2[1], forKey: .m32)
        try container.encode(elements.columns.2[2], forKey: .m33)
    }
}

extension Matrix3x3: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let m11 = try container.decode(Float.self, forKey: .m11)
        let m12 = try container.decode(Float.self, forKey: .m12)
        let m13 = try container.decode(Float.self, forKey: .m13)
        
        let m21 = try container.decode(Float.self, forKey: .m21)
        let m22 = try container.decode(Float.self, forKey: .m22)
        let m23 = try container.decode(Float.self, forKey: .m23)
        
        let m31 = try container.decode(Float.self, forKey: .m31)
        let m32 = try container.decode(Float.self, forKey: .m32)
        let m33 = try container.decode(Float.self, forKey: .m33)
        elements = simd_float3x3([SIMD3<Float>(m11, m12, m13),
                                  SIMD3<Float>(m21, m22, m23),
                                  SIMD3<Float>(m31, m32, m33)])
    }
}
