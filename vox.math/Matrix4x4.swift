//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Represents a 4x4 mathematical matrix.
public struct Matrix {
    /// An array containing the elements of the matrix (column matrix).
    /// - Remark:
    public var elements: simd_float4x4
    
    enum CodingKeys: String, CodingKey {
        case m11; case m12; case m13; case m14
        case m21; case m22; case m23; case m24
        case m31; case m32; case m33; case m34
        case m41; case m42; case m43; case m44
    }

    /// Constructor of 4x4 Matrix.
    /// - Parameters:
    ///   - m11: default 1, column 1, row 1
    ///   - m12: default 0, column 1, row 2
    ///   - m13: default 0, column 1, row 3
    ///   - m14: default 0, column 1, row 4
    ///   - m21: default 0, column 2, row 1
    ///   - m22: default 1, column 2, row 2
    ///   - m23: default 0, column 2, row 3
    ///   - m24: default 0, column 2, row 4
    ///   - m31: default 0, column 3, row 1
    ///   - m32: default 0, column 3, row 2
    ///   - m33: default 1, column 3, row 3
    ///   - m34: default 0, column 3, row 4
    ///   - m41: default 0, column 4, row 1
    ///   - m42: default 0, column 4, row 2
    ///   - m43: default 0, column 4, row 3
    ///   - m44: default 1, column 4, row 4
    public init(m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0,
                m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0,
                m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0,
                m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1) {
        elements = simd_float4x4([SIMD4<Float>(m11, m12, m13, m14),
                                  SIMD4<Float>(m21, m22, m23, m24),
                                  SIMD4<Float>(m31, m32, m33, m34),
                                  SIMD4<Float>(m41, m42, m43, m44)])
    }

    /// Constructor of 4x4 Matrix.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: simd_float4x4) {
        elements = array
    }
}

//MARK: - Static Methods

extension Matrix {
    /// Determines the product of two matrices.
    /// - Parameters:
    ///   - left: The first matrix to multiply
    ///   - right: The second matrix to multiply
    /// - Returns: The product of the two matrices
    public static func *(left: Matrix, right: Matrix) -> Matrix {
        Matrix(left.elements * right.elements)
    }

    public static func *=(left: inout Matrix, right: Matrix) {
        left.elements *= right.elements
    }

    /// Determines whether the specified matrices are equals.
    /// - Parameters:
    ///   - left: The first matrix to compare
    ///   - right: The second matrix to compare
    /// - Returns: True if the specified matrices are equals, false otherwise
    public static func equals(left: Matrix, right: Matrix) -> Bool {
        MathUtil.equals(left.elements.columns.0[0], right.elements.columns.0[0]) &&
                MathUtil.equals(left.elements.columns.0[1], right.elements.columns.0[1]) &&
                MathUtil.equals(left.elements.columns.0[2], right.elements.columns.0[2]) &&
                MathUtil.equals(left.elements.columns.0[3], right.elements.columns.0[3]) &&
                MathUtil.equals(left.elements.columns.1[0], right.elements.columns.1[0]) &&
                MathUtil.equals(left.elements.columns.1[1], right.elements.columns.1[1]) &&
                MathUtil.equals(left.elements.columns.1[2], right.elements.columns.1[2]) &&
                MathUtil.equals(left.elements.columns.1[3], right.elements.columns.1[3]) &&
                MathUtil.equals(left.elements.columns.2[0], right.elements.columns.2[0]) &&
                MathUtil.equals(left.elements.columns.2[1], right.elements.columns.2[1]) &&
                MathUtil.equals(left.elements.columns.2[2], right.elements.columns.2[2]) &&
                MathUtil.equals(left.elements.columns.2[3], right.elements.columns.2[3]) &&
                MathUtil.equals(left.elements.columns.3[0], right.elements.columns.3[0]) &&
                MathUtil.equals(left.elements.columns.3[1], right.elements.columns.3[1]) &&
                MathUtil.equals(left.elements.columns.3[2], right.elements.columns.3[2]) &&
                MathUtil.equals(left.elements.columns.3[3], right.elements.columns.3[3])
    }

    /// Performs a linear interpolation between two matrices.
    /// - Parameters:
    ///   - start: The first matrix
    ///   - end: The second matrix
    ///   - t: The blend amount where 0 returns start and 1 end
    /// - Returns: The result of linear blending between two matrices
    public static func lerp(start: Matrix, end: Matrix, t: Float) -> Matrix {
        Matrix(simd_linear_combination(1 - t, start.elements, t, end.elements))
    }

    /// Calculate a rotation matrix from a quaternion.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    /// - Returns: The calculated rotation matrix
    public static func rotationQuaternion(quaternion: Quaternion) -> Matrix {
        Matrix(matrix_float4x4(quaternion.elements))
    }

    /// Calculate a matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - r: The rotation angle in radians
    /// - Returns: The matrix after rotate
    public static func rotationAxisAngle(axis: Vector3, r: Float) -> Matrix {
        Matrix(matrix_float4x4(simd_quatf(angle: r, axis: axis.elements)))
    }


    /// Calculate a matrix from a quaternion and a translation.
    /// - Parameters:
    ///   - quaternion: The quaternion used to calculate the matrix
    ///   - translation: The translation used to calculate the matrix
    /// - Returns: The calculated matrix
    public static func rotationTranslation(quaternion: Quaternion, translation: Vector3) -> Matrix {
        var matrix = Matrix.rotationQuaternion(quaternion: quaternion)
        matrix.elements.columns.3[0] = translation.x
        matrix.elements.columns.3[1] = translation.y
        matrix.elements.columns.3[2] = translation.z
        return matrix
    }

    /// Calculate an affine matrix.
    /// - Parameters:
    ///   - scale: The scale used to calculate matrix
    ///   - rotation: The rotation used to calculate matrix
    ///   - translation: The translation used to calculate matrix
    /// - Returns: The calculated matrix
    public static func affineTransformation(scale: Vector3, rotation: Quaternion, translation: Vector3) -> Matrix {
        let x = rotation.x
        let y = rotation.y
        let z = rotation.z
        let w = rotation.w
        let x2 = x + x
        let y2 = y + y
        let z2 = z + z

        let xx = x * x2
        let xy = x * y2
        let xz = x * z2
        let yy = y * y2
        let yz = y * z2
        let zz = z * z2
        let wx = w * x2
        let wy = w * y2
        let wz = w * z2
        let sx = scale.x
        let sy = scale.y
        let sz = scale.z

        return Matrix(m11: (1 - (yy + zz)) * sx,
                m12: (xy + wz) * sx,
                m13: (xz - wy) * sx,
                m14: 0,

                m21: (xy - wz) * sy,
                m22: (1 - (xx + zz)) * sy,
                m23: (yz + wx) * sy,
                m24: 0,

                m31: (xz + wy) * sz,
                m32: (yz - wx) * sz,
                m33: (1 - (xx + yy)) * sz,
                m34: 0,

                m41: translation.x,
                m42: translation.y,
                m43: translation.z,
                m44: 1)
    }

    /// Calculate a matrix from scale vector.
    /// - Parameters:
    ///   - s: The scale vector
    /// - Returns: The calculated matrix
    public static func scaling(s: Vector3) -> Matrix {
        Matrix(m11: s.x,
                m12: 0,
                m13: 0,
                m14: 0,

                m21: 0,
                m22: s.y,
                m23: 0,
                m24: 0,

                m31: 0,
                m32: 0,
                m33: s.z,
                m34: 0,

                m41: 0,
                m42: 0,
                m43: 0,
                m44: 1)
    }

    /// Calculate a matrix from translation vector.
    /// - Parameters:
    ///   - translation: The translation vector
    /// - Returns: The calculated matrix
    public static func translation(translation: Vector3) -> Matrix {
        Matrix(m11: 1,
                m12: 0,
                m13: 0,
                m14: 0,

                m21: 0,
                m22: 1,
                m23: 0,
                m24: 0,

                m31: 0,
                m32: 0,
                m33: 1,
                m34: 0,

                m41: translation.x,
                m42: translation.y,
                m43: translation.z,
                m44: 1)
    }

    /// Calculate the inverse of the specified matrix.
    /// - Parameters:
    ///   - a: The matrix whose inverse is to be calculated
    /// - Returns: The inverse of the specified matrix
    public static func invert(a: Matrix) -> Matrix {
        Matrix(a.elements.inverse)
    }

    /// Calculate a right-handed look-at matrix.
    /// - Parameters:
    ///   - eye: The position of the viewer's eye
    ///   - target: The camera look-at target
    ///   - up: The camera's up vector
    /// - Returns: The calculated look-at matrix
    public static func lookAt(eye: Vector3, target: Vector3, up: Vector3) -> Matrix {
        var zAxis = eye - target
        _ = zAxis.normalize()
        var xAxis = Vector3.cross(left: up, right: zAxis)
        _ = xAxis.normalize()
        let yAxis = Vector3.cross(left: zAxis, right: xAxis)

        return Matrix(m11: xAxis.x,
                m12: yAxis.x,
                m13: zAxis.x,
                m14: 0,

                m21: xAxis.y,
                m22: yAxis.y,
                m23: zAxis.y,
                m24: 0,

                m31: xAxis.z,
                m32: yAxis.z,
                m33: zAxis.z,
                m34: 0,

                m41: -Vector3.dot(left: xAxis, right: eye),
                m42: -Vector3.dot(left: yAxis, right: eye),
                m43: -Vector3.dot(left: zAxis, right: eye),
                m44: 1)
    }

    /// Calculate an orthographic projection matrix.
    /// - Parameters:
    ///   - left: The left edge of the viewing
    ///   - right: The right edge of the viewing
    ///   - bottom: The bottom edge of the viewing
    ///   - top: The top edge of the viewing
    ///   - near: The depth of the near plane
    ///   - far: The depth of the far plane
    /// - Returns: The calculated orthographic projection matrix
    public static func ortho(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> Matrix {
        let lr = 1 / (left - right)
        let bt = 1 / (bottom - top)
        let nf = 1 / (near - far)

        return Matrix(m11: -2 * lr,
                m12: 0,
                m13: 0,
                m14: 0,

                m21: 0,
                m22: -2 * bt,
                m23: 0,
                m24: 0,

                m31: 0,
                m32: 0,
                m33: nf,
                m34: 0,

                m41: (left + right) * lr,
                m42: (top + bottom) * bt,
                m43: near * nf,
                m44: 1)
    }


    /// Calculate a perspective projection matrix.
    /// - Parameters:
    ///   - fovy: Field of view in the y direction, in radians
    ///   - aspect: Aspect ratio, defined as view space width divided by height
    ///   - near: The depth of the near plane
    ///   - far: The depth of the far plane
    /// - Returns: The calculated perspective projection matrix
    public static func perspective(fovy: Float, aspect: Float, near: Float, far: Float) -> Matrix {
        let f = 1.0 / tan(fovy / 2)
        let nf = 1 / (near - far)

        return Matrix(m11: f / aspect,
                m12: 0,
                m13: 0,
                m14: 0,

                m21: 0,
                m22: f,
                m23: 0,
                m24: 0,

                m31: 0,
                m32: 0,
                m33: far * nf,
                m34: -1,

                m41: 0,
                m42: 0,
                m43: far * near * nf,
                m44: 0)
    }

    /// The specified matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - m: The specified matrix
    ///   - axis: The axis
    ///   - r:  The rotation angle in radians
    /// - Returns: The rotated matrix
    public static func rotateAxisAngle(m: Matrix, axis: Vector3, r: Float) -> Matrix {
        Matrix(m.elements * matrix_float4x4(simd_quatf(angle: r, axis: axis.elements)))
    }

    /// Scale a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - s: The given vector
    /// - Returns: The scaled matrix
    public static func scale(m: Matrix, s: Vector3) -> Matrix {
        var elements = m.elements
        elements.columns.0 *= s.x
        elements.columns.1 *= s.y
        elements.columns.2 *= s.z
        return Matrix(elements)
    }

    /// Translate a matrix by a given vector.
    /// - Parameters:
    ///   - m: The matrix
    ///   - v: The given vector
    /// - Returns: The translated matrix
    public static func translate(m: Matrix, v: Vector3) -> Matrix {
        let x = v.x
        let y = v.y
        let z = v.z
        var elements = simd_float4x4()
        elements.columns.0 = m.elements.columns.0
        elements.columns.1 = m.elements.columns.1
        elements.columns.2 = m.elements.columns.2

        elements.columns.3[0] = m.elements.columns.0[0] * x + m.elements.columns.1[0] * y + m.elements.columns.2[0] * z + m.elements.columns.3[0]
        elements.columns.3[1] = m.elements.columns.0[1] * x + m.elements.columns.1[1] * y + m.elements.columns.2[1] * z + m.elements.columns.3[1]
        elements.columns.3[2] = m.elements.columns.0[2] * x + m.elements.columns.1[2] * y + m.elements.columns.2[2] * z + m.elements.columns.3[2]
        elements.columns.3[3] = m.elements.columns.0[3] * x + m.elements.columns.1[3] * y + m.elements.columns.2[3] * z + m.elements.columns.3[3]
        return Matrix(elements)
    }

    /// Calculate the transpose of the specified matrix.
    /// - Parameters:
    ///   - a: The specified matrix
    /// - Returns: The transpose of the specified matrix
    public static func transpose(a: Matrix) -> Matrix {
        Matrix(a.elements.transpose)
    }
}

//MARK: - Class Method

extension Matrix {
    /// Set the value of this matrix, and return this matrix.
    /// - Parameters:
    ///   - m11: column 1, row 1
    ///   - m12: column 1, row 2
    ///   - m13: column 1, row 3
    ///   - m14: column 1, row 4
    ///   - m21: column 2, row 1
    ///   - m22: column 2, row 2
    ///   - m23: column 2, row 3
    ///   - m24: column 2, row 4
    ///   - m31: column 3, row 1
    ///   - m32: column 3, row 2
    ///   - m33: column 3, row 3
    ///   - m34: column 3, row 4
    ///   - m41: column 4, row 1
    ///   - m42: column 4, row 2
    ///   - m43: column 4, row 3
    ///   - m44: column 4, row 4
    /// - Returns: This matrix
    mutating func set(m11: Float, m12: Float, m13: Float, m14: Float,
                             m21: Float, m22: Float, m23: Float, m24: Float,
                             m31: Float, m32: Float, m33: Float, m34: Float,
                             m41: Float, m42: Float, m43: Float, m44: Float) -> Matrix {
        elements.columns.0 = SIMD4<Float>(m11, m12, m13, m14)
        elements.columns.1 = SIMD4<Float>(m21, m22, m23, m24)
        elements.columns.2 = SIMD4<Float>(m31, m32, m33, m34)
        elements.columns.3 = SIMD4<Float>(m41, m42, m43, m44)

        return self
    }


    /// Set the value of this matrix by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This matrix
    mutating func set(array: Array<Float>, offset: Int = 0) -> Matrix {
        var index = 0
        for i in 0..<4 {
            for j in 0..<4 {
                elements[i, j] = array[index + offset]
                index += 1
            }
        }
        return self
    }

    /// Determines the product of this matrix and the specified matrix.
    /// - Parameter right: The specified matrix
    /// - Returns: This matrix that store the product of the two matrices
    public mutating func multiply(right: Matrix) -> Matrix {
        self = self * right
        return self
    }

    /// Identity this matrix.
    /// - Returns: This matrix after identity
    public mutating func identity() -> Matrix {
        elements = simd_float4x4(0)
        elements.columns.0[0] = 1
        elements.columns.1[1] = 1
        elements.columns.2[2] = 1
        elements.columns.3[3] = 1

        return self
    }

    /// Invert the matrix.
    /// - Returns: The matrix after invert
    public mutating func invert() -> Matrix {
        self = Matrix.invert(a: self)
        return self
    }

    /// This matrix rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - r: The rotation angle in radians
    /// - Returns: This matrix after rotate
    public mutating func rotateAxisAngle(axis: Vector3, r: Float) -> Matrix {
        self = Matrix.rotateAxisAngle(m: self, axis: axis, r: r)
        return self
    }

    /// Scale this matrix by a given vector.
    /// - Parameter s: The given vector
    /// - Returns: This matrix after scale
    public mutating func scale(s: Vector3) -> Matrix {
        self = Matrix.scale(m: self, s: s)
        return self
    }

    /// Translate this matrix by a given vector.
    /// - Parameter v: The given vector
    /// - Returns: This matrix after translate
    public mutating func translate(v: Vector3) -> Matrix {
        self = Matrix.translate(m: self, v: v)
        return self
    }

    /// Calculate the transpose of this matrix.
    /// - Returns: This matrix after transpose
    public mutating func transpose() -> Matrix {
        self = Matrix.transpose(a: self)
        return self
    }
}

extension Matrix {
    /// Clone the value of this matrix to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    public func toArray(out: inout [Float], outOffset: Int = 0) {
        out[outOffset] = elements.columns.0[0]
        out[outOffset + 1] = elements.columns.0[1]
        out[outOffset + 2] = elements.columns.0[2]
        out[outOffset + 3] = elements.columns.0[3]
        out[outOffset + 4] = elements.columns.1[0]
        out[outOffset + 5] = elements.columns.1[1]
        out[outOffset + 6] = elements.columns.1[2]
        out[outOffset + 7] = elements.columns.1[3]
        out[outOffset + 8] = elements.columns.2[0]
        out[outOffset + 9] = elements.columns.2[1]
        out[outOffset + 10] = elements.columns.2[2]
        out[outOffset + 11] = elements.columns.2[3]
        out[outOffset + 12] = elements.columns.3[0]
        out[outOffset + 13] = elements.columns.3[1]
        out[outOffset + 14] = elements.columns.3[2]
        out[outOffset + 15] = elements.columns.3[3]
    }

    /// Calculate a determinant of this matrix.
    /// - Returns: The determinant of this matrix
    public func determinant() -> Float {
        elements.determinant
    }


    /// Decompose this matrix to translation, rotation and scale elements.
    /// - Parameters:
    ///   - translation: Translation vector as an output parameter
    ///   - rotation: Rotation quaternion as an output parameter
    ///   - scale: Scale vector as an output parameter
    /// - Returns: True if this matrix can be decomposed, false otherwise
    public func decompose(translation: inout Vector3, rotation: inout Quaternion, scale: inout Vector3) -> Bool {
        let m11 = elements.columns.0[0]
        let m12 = elements.columns.0[1]
        let m13 = elements.columns.0[2]
        let m14 = elements.columns.0[3]
        let m21 = elements.columns.1[0]
        let m22 = elements.columns.1[1]
        let m23 = elements.columns.1[2]
        let m24 = elements.columns.1[3]
        let m31 = elements.columns.2[0]
        let m32 = elements.columns.2[1]
        let m33 = elements.columns.2[2]
        let m34 = elements.columns.2[3]

        translation = Vector3(elements.columns.3[0], elements.columns.3[1], elements.columns.3[2])

        let xs: Float = sign(m11 * m12 * m13 * m14) < 0 ? -1 : 1
        let ys: Float = sign(m21 * m22 * m23 * m24) < 0 ? -1 : 1
        let zs: Float = sign(m31 * m32 * m33 * m34) < 0 ? -1 : 1

        let sx = xs * sqrt(m11 * m11 + m12 * m12 + m13 * m13)
        let sy = ys * sqrt(m21 * m21 + m22 * m22 + m23 * m23)
        let sz = zs * sqrt(m31 * m31 + m32 * m32 + m33 * m33)

        scale = Vector3(sx, sy, sz)

        if (abs(sx) < Float.leastNonzeroMagnitude ||
                abs(sy) < Float.leastNonzeroMagnitude ||
                abs(sz) < Float.leastNonzeroMagnitude) {
            _ = rotation.identity()
            return false
        } else {
            let invSX = 1 / sx
            let invSY = 1 / sy
            let invSZ = 1 / sz

            rotation = Quaternion.rotationMatrix3x3(m: Matrix3x3(m11: m11 * invSX,
                    m12: m12 * invSX,
                    m13: m13 * invSX,
                    m21: m21 * invSY,
                    m22: m22 * invSY,
                    m23: m23 * invSY,
                    m31: m31 * invSZ,
                    m32: m32 * invSZ,
                    m33: m33 * invSZ))
            return true
        }
    }


    /// Get rotation from this matrix.
    /// - Returns: The out
    public func getRotation() -> Quaternion {
        Quaternion(simd_quatf(elements))
    }

    /// Get scale from this matrix.
    /// - Returns: The out
    public func getScaling() -> Vector3 {
        let m11 = elements.columns.0[0]
        let m12 = elements.columns.0[1]
        let m13 = elements.columns.0[2]
        let m21 = elements.columns.1[0]
        let m22 = elements.columns.1[1]
        let m23 = elements.columns.1[2]
        let m31 = elements.columns.2[0]
        let m32 = elements.columns.2[1]
        let m33 = elements.columns.2[2]

        return Vector3(sqrt(m11 * m11 + m12 * m12 + m13 * m13),
                sqrt(m21 * m21 + m22 * m22 + m23 * m23),
                sqrt(m31 * m31 + m32 * m32 + m33 * m33))
    }


    /// Get translation from this matrix.
    /// - Returns: The out
    public func getTranslation() -> Vector3 {
        Vector3(elements.columns.3[0],
                elements.columns.3[1],
                elements.columns.3[2])
    }
    
    public mutating func setTranslation(_ v: Vector3) {
        elements.columns.3[0] = v.x
        elements.columns.3[1] = v.y
        elements.columns.3[2] = v.z
    }
}

extension Matrix: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(elements.columns.0[0], forKey: .m11)
        try container.encode(elements.columns.0[1], forKey: .m12)
        try container.encode(elements.columns.0[2], forKey: .m13)
        try container.encode(elements.columns.0[3], forKey: .m14)

        try container.encode(elements.columns.1[0], forKey: .m21)
        try container.encode(elements.columns.1[1], forKey: .m22)
        try container.encode(elements.columns.1[2], forKey: .m23)
        try container.encode(elements.columns.1[3], forKey: .m24)

        try container.encode(elements.columns.2[0], forKey: .m31)
        try container.encode(elements.columns.2[1], forKey: .m32)
        try container.encode(elements.columns.2[2], forKey: .m33)
        try container.encode(elements.columns.2[3], forKey: .m34)

        try container.encode(elements.columns.3[0], forKey: .m41)
        try container.encode(elements.columns.3[1], forKey: .m42)
        try container.encode(elements.columns.3[2], forKey: .m43)
        try container.encode(elements.columns.3[3], forKey: .m44)
    }
}

extension Matrix: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let m11 = try container.decode(Float.self, forKey: .m11)
        let m12 = try container.decode(Float.self, forKey: .m12)
        let m13 = try container.decode(Float.self, forKey: .m13)
        let m14 = try container.decode(Float.self, forKey: .m14)

        let m21 = try container.decode(Float.self, forKey: .m21)
        let m22 = try container.decode(Float.self, forKey: .m22)
        let m23 = try container.decode(Float.self, forKey: .m23)
        let m24 = try container.decode(Float.self, forKey: .m24)

        let m31 = try container.decode(Float.self, forKey: .m31)
        let m32 = try container.decode(Float.self, forKey: .m32)
        let m33 = try container.decode(Float.self, forKey: .m33)
        let m34 = try container.decode(Float.self, forKey: .m34)

        let m41 = try container.decode(Float.self, forKey: .m41)
        let m42 = try container.decode(Float.self, forKey: .m42)
        let m43 = try container.decode(Float.self, forKey: .m43)
        let m44 = try container.decode(Float.self, forKey: .m44)
        elements = simd_float4x4([SIMD4<Float>(m11, m12, m13, m14),
                                  SIMD4<Float>(m21, m22, m23, m24),
                                  SIMD4<Float>(m31, m32, m33, m34),
                                  SIMD4<Float>(m41, m42, m43, m44)])
    }
}
