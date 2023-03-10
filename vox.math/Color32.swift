//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Representation of RGBA colors in 32 bit format.
public struct Color32 {
    /// Red component of the color.
    public var r: UInt8
    /// Green component of the color.
    public var g: UInt8
    /// Blue component of the color.
    public var b: UInt8
    /// Alpha component of the color.
    public var a: UInt8

    /// Constructs a new Color32 with given r, g, b, a components.
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(rgba: UInt32) {
        b = UInt8((rgba>>16) & 0xff)
        g = UInt8((rgba>>8)  & 0xff)
        r = UInt8((rgba)     & 0xff)
        a = 255
    }

    /// Linearly interpolates between colors a and b by t.
    public static func lerp(a: Color32, b: Color32, t: Float) -> Color32 {
        let t = MathUtil.clamp01(value: t)
        return Color32(r: UInt8(Double(a.r) + Double(Int(b.r) - Int(a.r)) * Double(t)),
                g: UInt8(Double(a.g) + Double(Int(b.g) - Int(a.g)) * Double(t)),
                b: UInt8(Double(a.b) + Double(Int(b.b) - Int(a.b)) * Double(t)),
                a: UInt8(Double(a.a) + Double(Int(b.a) - Int(a.a)) * Double(t)))
    }

    /// Linearly interpolates between colors a and b by t.
    public static func lerpUnclamped(a: Color32, b: Color32, t: Float) -> Color32 {
        Color32(r: UInt8(Double(a.r) + Double(Int(b.r) - Int(a.r)) * Double(t)),
                g: UInt8(Double(a.g) + Double(Int(b.g) - Int(a.g)) * Double(t)),
                b: UInt8(Double(a.b) + Double(Int(b.b) - Int(a.b)) * Double(t)),
                a: UInt8(Double(a.a) + Double(Int(b.a) - Int(a.a)) * Double(t)))
    }

    subscript(index: Int) -> UInt8 {
        get {
            switch (index) {
            case 0:
                return r
            case 1:
                return g
            case 2:
                return b
            case 3:
                return a
            default:
                fatalError("Invalid Color32 index(\(index)!")
            }
        }
        set {
            switch (index) {
            case 0:
                r = newValue
                break
            case 1:
                g = newValue
                break
            case 2:
                b = newValue
                break
            case 3:
                a = newValue
                break
            default:
                fatalError("Invalid Color32 index(\(index)!")
            }
        }
    }
}

extension Color32: Codable {
}

extension Color {
    public init(_ color32: Color32) {
        elements = SIMD4<Float>(Float(color32.r) / 255,
                                Float(color32.g) / 255,
                                Float(color32.b) / 255,
                                Float(color32.a) / 255)
    }
}
