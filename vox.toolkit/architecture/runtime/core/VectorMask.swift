//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

struct Vector2Mask {
    static let X: UInt8 = 1 << 0
    static let Y: UInt8 = 1 << 1

    public static let XY = Vector2Mask(X | Y)

    var m_Mask: UInt8

    public var x: Float {
        get {
            (m_Mask & Vector2Mask.X) == Vector2Mask.X ? 1 : 0
        }
    }

    public var y: Float {
        get {
            (m_Mask & Vector2Mask.Y) == Vector2Mask.Y ? 1 : 0
        }
    }

    public init(_ v: Vector3, epsilon: Float = Float.leastNonzeroMagnitude) {
        m_Mask = 0x0

        if (MathUtil.abs(v.x) > epsilon) {
            m_Mask |= Vector2Mask.X
        }
        if (MathUtil.abs(v.y) > epsilon) {
            m_Mask |= Vector2Mask.Y
        }
    }

    public init(_ mask: UInt8) {
        m_Mask = mask
    }

    public static func |(left: Vector2Mask, right: Vector2Mask) -> Vector2Mask {
        Vector2Mask(UInt8(left.m_Mask | right.m_Mask))
    }

    public static func &(left: Vector2Mask, right: Vector2Mask) -> Vector2Mask {
        Vector2Mask(UInt8(left.m_Mask & right.m_Mask))
    }

    public static func ^(left: Vector2Mask, right: Vector2Mask) -> Vector2Mask {
        Vector2Mask(UInt8(left.m_Mask ^ right.m_Mask))
    }

    public static func *(mask: Vector2Mask, value: Float) -> Vector2 {
        Vector2(mask.x * value, mask.y * value)
    }
}

struct Vector3Mask {
    static let X: UInt8 = 1 << 0
    static let Y: UInt8 = 1 << 1
    static let Z: UInt8 = 1 << 2

    public static let XYZ = Vector3Mask(X | Y | Z)

    var m_Mask: UInt8

    public var x: Float {
        get {
            return (m_Mask & Vector3Mask.X) == Vector3Mask.X ? 1 : 0
        }
    }

    public var y: Float {
        get {
            return (m_Mask & Vector3Mask.Y) == Vector3Mask.Y ? 1 : 0
        }
    }

    public var z: Float {
        get {
            return (m_Mask & Vector3Mask.Z) == Vector3Mask.Z ? 1 : 0
        }
    }

    public init(_ v: Vector3, epsilon: Float = Float.leastNonzeroMagnitude) {
        m_Mask = 0x0

        if (MathUtil.abs(v.x) > epsilon) {
            m_Mask |= Vector3Mask.X
        }
        if (MathUtil.abs(v.y) > epsilon) {
            m_Mask |= Vector3Mask.Y
        }
        if (MathUtil.abs(v.z) > epsilon) {
            m_Mask |= Vector3Mask.Z
        }
    }

    public init(_ mask: UInt8) {
        m_Mask = mask
    }

    /// The number of toggled axes.
    public var active: Int {
        get {
            var count = 0
            if ((m_Mask & Vector3Mask.X) > 0) {
                count += 1
            }
            if ((m_Mask & Vector3Mask.Y) > 0) {
                count += 1
            }
            if ((m_Mask & Vector3Mask.Z) > 0) {
                count += 1
            }
            return count
        }
    }

    public static func |(left: Vector3Mask, right: Vector3Mask) -> Vector3Mask {
        Vector3Mask(UInt8(left.m_Mask | right.m_Mask))
    }

    public static func &(left: Vector3Mask, right: Vector3Mask) -> Vector3Mask {
        Vector3Mask(UInt8(left.m_Mask & right.m_Mask))
    }

    public static func ^(left: Vector3Mask, right: Vector3Mask) -> Vector3Mask {
        Vector3Mask(UInt8(left.m_Mask ^ right.m_Mask))
    }

    public static func *(mask: Vector3Mask, value: Float) -> Vector3 {
        Vector3(mask.x * value, mask.y * value, mask.z * value)
    }

    public static func *(mask: Vector3Mask, value: Vector3) -> Vector3 {
        Vector3(mask.x * value.x, mask.y * value.y, mask.z * value.z)
    }

    public static func *(rotation: Quaternion, mask: Vector3Mask) -> Vector3 {
        let active = mask.active

        if (active > 2) {
            return Vector3(mask)
        }

        let rotated = (rotation * Vector3(mask)).abs()

        if (active > 1) {
            return Vector3(
                    rotated.x > rotated.y || rotated.x > rotated.z ? 1 : 0,
                    rotated.y > rotated.x || rotated.y > rotated.z ? 1 : 0,
                    rotated.z > rotated.x || rotated.z > rotated.y ? 1 : 0
            )
        }

        return Vector3(
                rotated.x > rotated.y && rotated.x > rotated.z ? 1 : 0,
                rotated.y > rotated.z && rotated.y > rotated.x ? 1 : 0,
                rotated.z > rotated.x && rotated.z > rotated.y ? 1 : 0)
    }
    
    subscript(i: Int) -> Float {
        get {
            Float(1 & (m_Mask >> i))
        }
        set {
            m_Mask &= UInt8(~(1 << i))
            m_Mask |= UInt8(((newValue > 0 ? 1 : 0) << i))
        }
    }
}

extension Vector3Mask : Hashable {
    
}

extension Vector3 {
    init(_ mask:Vector3Mask) {
        self = Vector3(mask.x, mask.y, mask.z)
    }
}
