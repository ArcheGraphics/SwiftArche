//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Represents a four dimensional mathematical quaternion.
public struct Quaternion {
    var elements: simd_quatf

    public var x: Float {
        get {
            elements.imag.x
        }
    }

    public var y: Float {
        get {
            elements.imag.y
        }
    }

    public var z: Float {
        get {
            elements.imag.z
        }
    }

    public var w: Float {
        get {
            elements.real
        }
    }

    public var axis: Vector3 {
        get {
            Vector3(elements.axis)
        }
    }

    public var angle: Float {
        get {
            elements.angle
        }
    }

    public var internalValue: simd_quatf {
        get {
            elements
        }
    }

    public init() {
        elements = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }

    /// Constructor of Quaternion.
    /// - Parameters:
    ///   - x: The x component of the quaternion, default 0
    ///   - y: The y component of the quaternion, default 0
    ///   - z: The z component of the quaternion, default 0
    ///   - w: The w component of the quaternion, default 1
    public init(_ x: Float = 0, _ y: Float = 0, _ z: Float = 0, _ w: Float = 1) {
        elements = simd_quatf(ix: x, iy: y, iz: z, r: w)
    }

    /// Constructor of Quaternion.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: simd_quatf) {
        elements = array
    }
}

//MARK:- Static Methods

extension Quaternion {
    /// Determines the sum of two vectors.
    /// - Parameters:
    ///   - left: The first vector to add
    ///   - right: The second vector to add
    /// - Returns: The sum of two vectors
    public static func +(left: Quaternion, right: Quaternion) -> Quaternion {
        Quaternion(left.elements + right.elements)
    }

    public static func +=(left: inout Quaternion, right: Quaternion) {
        left.elements += right.elements
    }

    /// Determines the product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to multiply
    ///   - right: The second vector to multiply
    /// - Returns: The product of two vectors
    public static func *(left: Quaternion, right: Quaternion) -> Quaternion {
        Quaternion(left.elements * right.elements)
    }

    public static func *=(left: inout Quaternion, right: Quaternion) {
        left.elements *= right.elements
    }

    /// Scale a vector by the given value.
    /// - Parameters:
    ///   - left: The vector to scale
    ///   - s: The amount by which to scale the vector
    /// - Returns: The scaled vector
    public static func *(left: Quaternion, s: Float) -> Quaternion {
        Quaternion(left.elements * s)
    }

    public static func *=(left: inout Quaternion, right: Float) {
        left.elements *= right
    }
}

extension Quaternion {
    /// Calculate quaternion that contains conjugated version of the specified quaternion.
    /// - Parameters:
    ///   - a: The specified quaternion
    /// - Returns: The conjugate version of the specified quaternion
    public static func conjugate(a: Quaternion) -> Quaternion {
        Quaternion(a.elements.conjugate)
    }

    /// Determines the dot product of two vectors.
    /// - Parameters:
    ///   - left: The first vector to dot
    ///   - right: The second vector to dot
    /// - Returns: The dot product of two vectors
    public static func dot(left: Quaternion, right: Quaternion) -> Float {
        simd_dot(left.elements, right.elements)
    }

    /// Determines whether the specified vectors are equals.
    /// - Parameters:
    ///   - left: The first vector to compare
    ///   - right: The second vector to compare
    /// - Returns: True if the specified vectors are equals, false otherwise
    public static func equals(left: Quaternion, right: Quaternion) -> Bool {
        MathUtil.equals(left.x, right.x) &&
                MathUtil.equals(left.y, right.y) &&
                MathUtil.equals(left.z, right.z) &&
                MathUtil.equals(left.w, right.w)
    }

    /// Calculate a quaternion rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - rad: The rotation angle in radians
    /// - Returns: The quaternion after rotate
    public static func rotationAxisAngle(axis: Vector3, rad: Float) -> Quaternion {
        var axis = axis
        return Quaternion(simd_quatf(angle: rad, axis: axis.normalize().elements))
    }

    /// Calculate a quaternion from the specified yaw, pitch and roll angles.
    /// - Parameters:
    ///   - yaw: Yaw around the y axis in radians
    ///   - pitch: Pitch around the x axis in radians
    ///   - roll: Roll around the z axis in radians
    /// - Returns: The calculated quaternion
    public static func rotationYawPitchRoll(yaw: Float, pitch: Float, roll: Float) -> Quaternion {
        let halfRoll = roll * 0.5
        let halfPitch = pitch * 0.5
        let halfYaw = yaw * 0.5

        let sinRoll = sin(halfRoll)
        let cosRoll = cos(halfRoll)
        let sinPitch = sin(halfPitch)
        let cosPitch = cos(halfPitch)
        let sinYaw = sin(halfYaw)
        let cosYaw = cos(halfYaw)

        let cosYawPitch = cosYaw * cosPitch
        let sinYawPitch = sinYaw * sinPitch

        return Quaternion(cosYaw * sinPitch * cosRoll + sinYaw * cosPitch * sinRoll,
                sinYaw * cosPitch * cosRoll - cosYaw * sinPitch * sinRoll,
                cosYawPitch * sinRoll - sinYawPitch * cosRoll,
                cosYawPitch * cosRoll + sinYawPitch * sinRoll)
    }

    /// Calculate a quaternion rotates around x, y, z axis (pitch/yaw/roll).
    /// - Parameters:
    ///   - x: The radian of rotation around X (pitch)
    ///   - y: The radian of rotation around Y (yaw)
    ///   - z: The radian of rotation around Z (roll)
    /// - Returns: The calculated quaternion
    public static func rotationEuler(x: Float, y: Float, z: Float) -> Quaternion {
        Quaternion.rotationYawPitchRoll(yaw: y, pitch: x, roll: z)
    }

    /// Calculate a quaternion from the specified 3x3 matrix.
    /// - Parameters:
    ///   - m: The specified 3x3 matrix
    /// - Returns: The calculated quaternion
    public static func rotationMatrix3x3(m: Matrix3x3) -> Quaternion {
        Quaternion(simd_quatf(m.elements))
    }

    /// Calculate the inverse of the specified quaternion.
    /// - Parameters:
    ///   - a: The quaternion whose inverse is to be calculated
    /// - Returns: The inverse of the specified quaternion
    public static func invert(a: Quaternion) -> Quaternion {
        Quaternion(a.elements.inverse)
    }

    /// Performs a spherical linear blend between two quaternions.
    /// - Parameters:
    ///   - start: The first quaternion
    ///   - end: The second quaternion
    ///   - t: The blend amount where 0 returns start and 1 end
    /// - Returns: The result of spherical linear blending between two quaternions
    public static func slerp(start: Quaternion, end: Quaternion, t: Float) -> Quaternion {
        Quaternion(simd_slerp(start.elements, end.elements, t))
    }

    /// Converts the vector into a unit vector.
    /// - Parameters:
    ///   - left: The vector to normalize
    /// - Returns: The normalized vector
    public static func normalize(left: Quaternion) -> Quaternion {
        Quaternion(simd_normalize(left.elements))
    }

    /// Calculate a quaternion rotate around X axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotationX(rad: Float) -> Quaternion {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        return Quaternion(s, 0, 0, c)
    }

    /// Calculate a quaternion rotate around Y axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotationY(rad: Float) -> Quaternion {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        return Quaternion(0, s, 0, c)
    }

    /// Calculate a quaternion rotate around Z axis.
    /// - Parameters:
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotationZ(rad: Float) -> Quaternion {
        let rad = rad * 0.5
        let s = sin(rad)
        let c = cos(rad)

        return Quaternion(0, 0, s, c)
    }

    /// Calculate a quaternion that the specified quaternion rotate around X axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotateX(quaternion: Quaternion, rad: Float) -> Quaternion {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let bx = sin(rad)
        let bw = cos(rad)

        return Quaternion(x * bw + w * bx,
                y * bw + z * bx,
                z * bw - y * bx,
                w * bw - x * bx)
    }

    /// Calculate a quaternion that the specified quaternion rotate around Y axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotateY(quaternion: Quaternion, rad: Float) -> Quaternion {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let by = sin(rad)
        let bw = cos(rad)

        return Quaternion(x * bw - z * by,
                y * bw + w * by,
                z * bw + x * by,
                w * bw - y * by)
    }

    /// Calculate a quaternion that the specified quaternion rotate around Z axis.
    /// - Parameters:
    ///   - quaternion: The specified quaternion
    ///   - rad: The rotation angle in radians
    /// - Returns: The calculated quaternion
    public static func rotateZ(quaternion: Quaternion, rad: Float) -> Quaternion {
        let x = quaternion.x
        let y = quaternion.y
        let z = quaternion.z
        let w = quaternion.w
        let rad = rad * 0.5
        let bz = sin(rad)
        let bw = cos(rad)

        return Quaternion(x * bw + y * bz,
                y * bw - x * bz,
                z * bw + w * bz,
                w * bw - z * bz)
    }
}

extension Quaternion {
    /// Set the value of this vector.
    /// - Parameters:
    ///   - x: The x component of the vector
    ///   - y: The y component of the vector
    ///   - z: The z component of the vector
    ///   - w: The w component of the vector
    /// - Returns: This vector
    mutating func set(x: Float, y: Float, z: Float, w: Float) -> Quaternion {
        elements = simd_quatf(ix: x, iy: y, iz: z, r: w)
        return self
    }

    /// Set the value of this vector by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    /// - Returns: This vector
    mutating func set(array: Array<Float>, offset: Int = 0) -> Quaternion {
        elements = simd_quatf(ix: array[offset],
                iy: array[offset + 1],
                iz: array[offset + 2],
                r: array[offset + 2])
        return self
    }

    /// Transforms this quaternion into its conjugated version.
    /// - Returns: This quaternion
    public mutating func conjugate() -> Quaternion {
        elements = elements.conjugate
        return self
    }

    /// Identity this quaternion.
    /// - Returns: This quaternion after identity
    public mutating func identity() -> Quaternion {
        elements = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)

        return self
    }


    /// Converts this quaternion into a unit quaternion.
    /// - Returns: This quaternion
    public mutating func normalize() -> Quaternion {
        if simd_length(elements) > Float.leastNonzeroMagnitude {
            self = Quaternion.normalize(left: self)
        }
        return self
    }

    /// Calculate this quaternion rotate around X axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    public mutating func rotateX(rad: Float) -> Quaternion {
        self = Quaternion.rotateX(quaternion: self, rad: rad)
        return self
    }

    /// Calculate this quaternion rotate around Y axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    public mutating func rotateY(rad: Float) -> Quaternion {
        self = Quaternion.rotateY(quaternion: self, rad: rad)
        return self
    }

    /// Calculate this quaternion rotate around Z axis.
    /// - Parameter rad: The rotation angle in radians
    /// - Returns: This quaternion
    public mutating func rotateZ(rad: Float) -> Quaternion {
        self = Quaternion.rotateZ(quaternion: self, rad: rad)
        return self
    }

    /// Calculate this quaternion rotates around an arbitrary axis.
    /// - Parameters:
    ///   - axis: The axis
    ///   - rad: The rotation angle in radians
    /// - Returns: This quaternion
    public mutating func rotationAxisAngle(axis: Vector3, rad: Float) -> Quaternion {
        self = Quaternion.rotationAxisAngle(axis: axis, rad: rad)
        return self
    }

    /// Determines the product of this quaternion and the specified quaternion.
    /// - Parameter quat: The specified quaternion
    /// - Returns: The product of the two quaternions
    public mutating func multiply(quat: Quaternion) -> Quaternion {
        self = self * quat
        return self
    }

    /// Invert this quaternion.
    /// - Returns: This quaternion after invert
    public mutating func invert() -> Quaternion {
        self = Quaternion.invert(a: self)
        return self
    }

    /// Performs a linear blend between this quaternion and the specified quaternion.
    /// - Parameters:
    ///   - quat: The specified quaternion
    ///   - t: The blend amount where 0 returns this and 1 quat
    /// - Returns: The result of linear blending between two quaternions
    public mutating func lerp(quat: Quaternion, t: Float) -> Quaternion {
        self = Quaternion.slerp(start: self, end: quat, t: t)
        return self
    }
}

extension Quaternion {
    /// Determines the dot product of this quaternion and the specified quaternion.
    /// - Parameter quat: The specified quaternion
    /// - Returns: The dot product of two quaternions
    public func dot(quat: Quaternion) -> Float {
        Quaternion.dot(left: self, right: quat)
    }

    /// Calculate the length of this quaternion.
    /// - Returns: The length of this quaternion
    public func length() -> Float {
        elements.length
    }

    /// Calculates the squared length of this quaternion.
    /// - Returns: The squared length of this quaternion
    public func lengthSquared() -> Float {
        x * x + y * y + z * z + w * w
    }

    /// Get the euler of this quaternion.
    /// - Returns: Euler x->pitch y->yaw z->roll
    public func toEuler() -> Vector3 {
        let out = toYawPitchRoll()
        return Vector3(out.y, out.x, out.z)
    }

    /// Get the euler of this quaternion.
    /// - Returns: Euler x->yaw y->pitch z->roll
    public func toYawPitchRoll() -> Vector3 {
        let xx = x * x
        let yy = y * y
        let zz = z * z
        let xy = x * y
        let zw = z * w
        let zx = z * x
        let yw = y * w
        let yz = y * z
        let xw = x * w

        let y = asin(2.0 * (xw - yz))
        var x: Float = 0
        var z: Float = 0
        if (cos(y) > Float.leastNonzeroMagnitude) {
            z = atan2(2.0 * (xy + zw), 1.0 - 2.0 * (zz + xx))
            x = atan2(2.0 * (zx + yw), 1.0 - 2.0 * (yy + xx))
        } else {
            z = atan2(-2.0 * (xy - zw), 1.0 - 2.0 * (yy + zz))
            x = 0.0
        }

        return Vector3(x, y, z)
    }

    /// Clone the value of this quaternion to an array.
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
