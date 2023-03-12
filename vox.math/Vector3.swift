//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a 3D-vector.
public struct Vector3 {
    public static let zero = Vector3(0.0, 0.0, 0.0)
    public static let one = Vector3(1, 1, 1)
    public static let up = Vector3(0.0, 1, 0.0)
    public static let down = Vector3(0.0, -1, 0.0)
    public static let left = Vector3(-1, 0.0, 0.0)
    public static let right = Vector3(1, 0.0, 0.0)
    public static let forward = Vector3(0.0, 0.0, 1)
    public static let back = Vector3(0.0, 0.0, -1)

    /// An array containing the elements of the vector
    var elements: SIMD3<Float>

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

    public var internalValue: SIMD3<Float> {
        get {
            elements
        }
    }

    public init() {
        elements = SIMD3<Float>(0, 0, 0)
    }

    public init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0) {
        elements = SIMD3<Float>(x, y, z)
    }

    /// Constructor of Vector3.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: SIMD3<Float>) {
        elements = array
    }
}

//MARK: - Static Methods
extension Vector3: Equatable {

}

extension Vector3 {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    public static func +(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements + right.elements)
    }

    public static func +=(left: inout Vector3, right: Vector3) {
        left.elements += right.elements
    }

    /// Determines the difference between two vectors.
    /// - Parameters:
    ///   - left: The first vector to subtract
    ///   - right: The second vector to subtract
    /// - Returns: The difference between two vectors
    public static func -(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements - right.elements)
    }

    public static func -=(left: inout Vector3, right: Vector3) {
        left.elements -= right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    public static func *(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements * right.elements)
    }
    
    public static func *(left: Vector3, right: Quaternion) -> Vector3 {
        Vector3.transformByQuat(v: left, quaternion: right)
    }
    
    public static func *(left: Quaternion, right: Vector3) -> Vector3 {
        Vector3.transformByQuat(v: right, quaternion: left)
    }

    public static func *=(left: inout Vector3, right: Vector3) {
        left.elements *= right.elements
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    public static func *(left: Vector3, s: Float) -> Vector3 {
        Vector3(left.elements * s)
    }
    
    public static func *(s: Float, right: Vector3) -> Vector3 {
        Vector3(right.elements * s)
    }

    public static func *=(left: inout Vector3, right: Float) {
        left.elements *= right
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    public static func /(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.elements / right.elements)
    }

    public static func /=(left: inout Vector3, right: Vector3) {
        left.elements /= right.elements
    }

    /// Determines the divisor of two vectors.
    /// - Parameters:
    ///   - left: The first vector to divide
    ///   - right: The second vector to divide
    /// - Returns: The divisor of two vectors
    public static func /(left: Vector3, right: Float) -> Vector3 {
        Vector3(left.elements / right)
    }

    public static func /=(left: inout Vector3, right: Float) {
        left.elements /= right
    }

    /// Reverses the direction of a given vector.
    /// - Parameters:
    ///   - left: The vector to negate
    /// - Returns: The vector facing in the opposite direction
    public static prefix func -(left: Vector3) -> Vector3 {
        Vector3(-left.elements)
    }
}

extension Vector3 {
    public func abs() -> Vector3 {
        return Vector3(MathUtil.abs(x), MathUtil.abs(y), MathUtil.abs(z))
    }

    public func sign() -> Vector3 {
        return Vector3(MathUtil.sign(x), MathUtil.sign(y), MathUtil.sign(z))
    }

    public func sum() -> Float {
        return MathUtil.abs(x) + MathUtil.abs(y) + MathUtil.abs(z)
    }
    
    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    public static func dot(left: Vector3, right: Vector3) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines the cross product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to cross
    ///   - right: The second vector to cross
    /// - Returns: The cross product of two vectors
    public static func cross(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_cross(left.elements, right.elements))
    }

    /// Determines the distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The distance of two vectors
    public static func distance(left: Vector3, right: Vector3) -> Float {
        simd_distance(left.elements, right.elements)
    }

    /// Determines the squared distance of two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The squared distance of two vectors
    public static func distanceSquared(left: Vector3, right: Vector3) -> Float {
        simd_distance_squared(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    public static func equals(left: Vector3, right: Vector3) -> Bool {
        MathUtil.equals(left.x, right.x) && MathUtil.equals(left.y, right.y) && MathUtil.equals(left.z, right.z)
    }

    /// Performs a linear interpolation between two vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    ///   - t: The blend amount where 0 returns left and 1 right
    /// - Returns: The result of linear blending between two vectors
    public static func lerp(left: Vector3, right: Vector3, t: Float) -> Vector3 {
        Vector3(mix(left.elements, right.elements, t: t))
    }

    /// Calculate a vector containing the largest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the largest components of the specified vectors
    public static func max(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_max(left.elements, right.elements))
    }

    /// Calculate a vector containing the smallest components of the specified vectors.
    /// - Parameters:
    ///   - left: The first vector
    ///   - right: The second vector
    /// - Returns: The vector containing the smallest components of the specified vectors
    public static func min(left: Vector3, right: Vector3) -> Vector3 {
        Vector3(simd_min(left.elements, right.elements))
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    /// - Returns: The normalized vector
    public static func normalize(left: Vector3) -> Vector3 {
        Vector3(simd_normalize(left.elements))
    }
}

//MARK: - Static Method: Transformation

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
    public static func transformNormal(v: Vector3, m: Matrix) -> Vector3 {
        let x = v.x
        let y = v.y
        let z = v.z
        return Vector3(x * m.elements.columns.0[0] + y * m.elements.columns.1[0] + z * m.elements.columns.2[0],
                x * m.elements.columns.0[1] + y * m.elements.columns.1[1] + z * m.elements.columns.2[1],
                x * m.elements.columns.0[2] + y * m.elements.columns.1[2] + z * m.elements.columns.2[2])
    }
    
    public static func transformNormal(v: Vector3, m: Matrix3x3) -> Vector3 {
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
    public static func transformToVec3(v: Vector3, m: Matrix) -> Vector3 {
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
    public static func transformToVec4(v: Vector3, m: Matrix) -> Vector4 {
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
    public static func transformCoordinate(v: Vector3, m: Matrix) -> Vector3 {
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
    public static func transformByQuat(v: Vector3, quaternion: Quaternion) -> Vector3 {
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

    public static func SmoothDamp(current: Vector3, target: Vector3, currentVelocity: inout Vector3,
                                  smoothTime: Float, deltaTime: Float,
                                  maxSpeed: Float = Float.greatestFiniteMagnitude) -> Vector3 {
        var target = target
        let smoothTime: Float = Swift.max(0.0001, smoothTime)
        let num1: Float = 2 / smoothTime
        let num2: Float = num1 * deltaTime
        let num3: Float = (1.0 / (1.0 + num2 + 0.47999998927116394 * num2 * num2 + 0.23499999940395355 * num2 * num2 * num2))
        var num4: Float = current.x - target.x
        var num5: Float = current.y - target.y
        var num6: Float = current.z - target.z
        let vector3 = target
        let num7 = maxSpeed * smoothTime
        let num8 = num7 * num7
        let d = (num4 * num4 + num5 * num5 + num6 * num6)
        if (d > num8) {
            let num9 = sqrt(d)
            num4 = num4 / num9 * num7
            num5 = num5 / num9 * num7
            num6 = num6 / num9 * num7
        }
        target.x = current.x - num4
        target.y = current.y - num5
        target.z = current.z - num6
        let num10 = (currentVelocity.x + num1 * num4) * deltaTime
        let num11 = (currentVelocity.y + num1 * num5) * deltaTime
        let num12 = (currentVelocity.z + num1 * num6) * deltaTime
        currentVelocity.x = (currentVelocity.x - num1 * num10) * num3
        currentVelocity.y = (currentVelocity.y - num1 * num11) * num3
        currentVelocity.z = (currentVelocity.z - num1 * num12) * num3
        var x = target.x + (num4 + num10) * num3
        var y = target.y + (num5 + num11) * num3
        var z = target.z + (num6 + num12) * num3
        let num13 = vector3.x - current.x
        let num14 = vector3.y - current.y
        let num15 = vector3.z - current.z
        let num16 = x - vector3.x
        let num17 = y - vector3.y
        let num18 = z - vector3.z
        if (num13 * num16 + num14 * num17 + num15 * num18 > 0.0) {
            x = vector3.x
            y = vector3.y
            z = vector3.z
            currentVelocity.x = (x - vector3.x) / deltaTime
            currentVelocity.y = (y - vector3.y) / deltaTime
            currentVelocity.z = (z - vector3.z) / deltaTime
        }
        return Vector3(x, y, z)
    }

    /// Calculates the angle between vectors from and.
    /// - Parameters:
    ///   - from: The vector from which the angular difference is measured.
    ///   - to: The vector to which the angular difference is measured.
    /// - Returns: The angle in degrees between the two vectors.
    public static func angle(from: Vector3, to: Vector3) -> Float {
        let num = sqrt(from.lengthSquared() * to.lengthSquared())
        return num < 1.0000000036274937E-15 ? 0.0 : acos(simd_clamp(Vector3.dot(left: from, right: to) / num, -1, 1)) * 57.29578
    }

    /// Calculate a position between the points specified by current and target, moving no farther than the distance specified by maxDistanceDelta.
    /// - Parameters:
    ///   - current: The position to move from.
    ///   - target: The position to move towards.
    ///   - maxDistanceDelta: Distance to move current per call.
    /// - Returns: The new position
    public static func moveTowards(current: Vector3, target: Vector3, maxDistanceDelta: Float) -> Vector3 {
        let num1 = target.x - current.x
        let num2 = target.y - current.y
        let num3 = target.z - current.z
        let d = num1 * num1 + num2 * num2 + num3 * num3
        if (d == 0.0 || maxDistanceDelta >= 0.0 && d <= maxDistanceDelta * maxDistanceDelta) {
            return target
        }
        let num4 = sqrt(d)
        return Vector3(current.x + num1 / num4 * maxDistanceDelta,
                current.y + num2 / num4 * maxDistanceDelta,
                current.z + num3 / num4 * maxDistanceDelta)
    }

    /// Projects a vector onto another vector.
    public static func project(vector: Vector3, onNormal: Vector3) -> Vector3 {
        let num1 = simd_dot(onNormal.elements, onNormal.elements)
        if (num1 < Float.leastNonzeroMagnitude) {
            return Vector3.zero
        }
        let num2 = simd_dot(vector.elements, onNormal.elements)
        return Vector3(onNormal.x * num2 / num1, onNormal.y * num2 / num1, onNormal.z * num2 / num1)
    }

    /// Projects a vector onto a plane defined by a normal orthogonal to the plane.
    /// - Parameters:
    ///   - vector: The direction from the vector towards the plane.
    ///   - planeNormal: The location of the vector above the plane.
    /// - Returns: The location of the vector on the plane.
    public static func projectOnPlane(vector: Vector3, planeNormal: Vector3) -> Vector3 {
        let num1 = simd_dot(planeNormal.elements, planeNormal.elements)
        if (num1 < Float.leastNonzeroMagnitude) {
            return vector
        }
        let num2 = simd_dot(vector.elements, planeNormal.elements)
        return Vector3(vector.x - planeNormal.x * num2 / num1, vector.y - planeNormal.y * num2 / num1, vector.z - planeNormal.z * num2 / num1)
    }

    /// Returns a copy of vector with its magnitude clamped to maxLength.
    public static func clampMagnitude(vector: Vector3, maxLength: Float) -> Vector3 {
        let sqrMagnitude = vector.lengthSquared()
        if (sqrMagnitude <= maxLength * maxLength) {
            return vector
        }
        let num1 = sqrt(sqrMagnitude)
        let num2 = vector.x / num1
        let num3 = vector.y / num1
        let num4 = vector.z / num1
        return Vector3(num2 * maxLength, num3 * maxLength, num4 * maxLength)
    }
}

//MARK: - Class Method

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
    public mutating func add(right: Vector3) -> Vector3 {
        elements += right.elements
        return self
    }

    /// Determines the difference of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func subtract(right: Vector3) -> Vector3 {
        elements -= right.elements
        return self
    }

    /// Determines the product of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func multiply(right: Vector3) -> Vector3 {
        elements *= right.elements
        return self
    }

    /// Determines the divisor of this vector and the specified vector.
    /// - Parameter right: The specified vector
    /// - Returns: This vector
    public mutating func divide(right: Vector3) -> Vector3 {
        elements /= right.elements
        return self
    }


    /// Reverses the direction of this vector.
    /// - Returns: This vector
    public mutating func negate() -> Vector3 {
        elements = -elements
        return self
    }

    /// Converts this vector into a unit vector.
    /// - Returns: This vector
    public mutating func normalize() -> Vector3 {
        if simd_length_squared(elements) > Float.leastNonzeroMagnitude {
            elements = simd_normalize(elements)
        }
        return self
    }

    public func normalized() -> Vector3 {
        if simd_length_squared(elements) > Float.leastNonzeroMagnitude {
            return Vector3(simd_normalize(elements))
        }
        return Vector3(1, 0, 0)
    }

    /// Scale this vector by the given value.
    /// - Parameter s: The amount by which to scale the vector
    /// - Returns: This vector
    public mutating func scale(s: Float) -> Vector3 {
        elements *= s
        return self
    }

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
    
    public func cross(_ left: Vector3) -> Vector3 {
        Vector3(simd_cross(elements, left.elements))
    }

    /// Clone the value of this vector to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    public func toArray(out: inout [Float], outOffset: Int = 0) {
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
    public mutating func transformNormal(m: Matrix) -> Vector3 {
        self = Vector3.transformNormal(v: self, m: m)
        return self
    }

    /// This vector performs a transformation using the given 4x4 matrix.
    /// - Parameter m: The transform matrix
    /// - Returns: This vector
    public mutating func transformToVec3(m: Matrix) -> Vector3 {
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
    public mutating func transformCoordinate(m: Matrix) -> Vector3 {
        self = Vector3.transformCoordinate(v: self, m: m)
        return self
    }

    /// This vector performs a transformation using the given quaternion.
    /// - Parameter quaternion: The transform quaternion
    /// - Returns: This vector
    public mutating func transformByQuat(quaternion: Quaternion) -> Vector3 {
        self = Vector3.transformByQuat(v: self, quaternion: quaternion)
        return self
    }
}

extension Vector3: Codable {
}
