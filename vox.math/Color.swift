//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a color in the from of RGBA (in order: R, G, B, A).
public struct Color {
    /// Solid red. RGBA is (1, 0, 0, 1).
    public static let red = Color(1, 0.0, 0.0, 1)
    /// Solid green. RGBA is (0, 1, 0, 1).
    public static let green = Color(0.0, 1, 0.0, 1)
    /// Solid blue. RGBA is (0, 0, 1, 1).
    public static let blue = Color(0.0, 0.0, 1, 1)
    /// >Solid white. RGBA is (1, 1, 1, 1).
    public static let white = Color(1, 1, 1, 1)
    /// Solid black. RGBA is (0, 0, 0, 1).
    public static let black = Color(0.0, 0.0, 0.0, 1)
    /// Yellow. RGBA is (1, 0.92, 0.016, 1), but the color is nice to look at!
    public static let yellow = Color(1, 0.92156863, 0.015686275, 1)
    /// Cyan. RGBA is (0, 1, 1, 1).
    public static let cyan = Color(0.0, 1, 1, 1)
    /// Magenta. RGBA is (1, 0, 1, 1).
    public static let magenta = Color(1, 0.0, 1, 1)
    /// Gray. RGBA is (0.5, 0.5, 0.5, 1).
    public static let gray = Color(0.5, 0.5, 0.5, 1)
    /// English spelling for gray. RGBA is the same (0.5, 0.5, 0.5, 1).
    public static let grey = Color(0.5, 0.5, 0.5, 1)
    /// Completely transparent. RGBA is (0, 0, 0, 0).
    public static let clear = Color(0.0, 0.0, 0.0, 0.0)
    /// The grayscale value of the color. (Read Only)
    public var grayscale: Float {
        Float(0.29899999499320984 * Double(r) + 0.5870000123977661 * Double(g) + 57.0 / 500.0 * Double(b))
    }

    /// The color component of the color, 0~1.
    var elements: SIMD4<Float>

    /// The red component of the color, 0~1.
    public var r: Float {
        get {
            elements.x
        }
        set {
            elements.x = newValue
        }
    }
    /// The green component of the color, 0~1.
    public var g: Float {
        get {
            elements.y
        }
        set {
            elements.y = newValue
        }
    }
    /// The blue component of the color, 0~1.
    public var b: Float {
        get {
            elements.z
        }
        set {
            elements.z = newValue
        }
    }
    /// The alpha component of the color, 0~1.
    public var a: Float {
        get {
            elements.w
        }
        set {
            elements.w = newValue
        }
    }

    public var rgb: SIMD3<Float> {
        get {
            SIMD3<Float>(r, g, b)
        }
    }

    public var internalValue: SIMD4<Float> {
        get {
            elements
        }
    }

    public init() {
        elements = SIMD4<Float>(1, 1, 1, 1)
    }

    /// Constructor of Color.
    /// - Parameters:
    ///   - r: The red component of the color
    ///   - g: The green component of the color
    ///   - b: The blue component of the color
    ///   - a: The alpha component of the color
    public init(_ r: Float = 1, _ g: Float = 1, _ b: Float = 1, _ a: Float = 1) {
        elements = [r, g, b, a]
    }

    /// Constructor of Color.
    /// - Parameters:
    ///   - array: The component of the vector
    public init(_ array: SIMD4<Float>) {
        elements = array
    }

    public init(_ array: SIMD3<Float>, _ alpha: Float = 1) {
        elements = SIMD4<Float>(array, alpha)
    }
}

extension Color {
    /// Determines the sum of two colors.
    /// - Parameters:
    ///   - left: The first color to add
    ///   - right: The second color to add
    /// - Returns: The sum of two colors
    public static func +(left: Color, right: Color) -> Color {
        Color(left.elements + right.elements)
    }

    public static func +=(left: inout Color, right: Color) {
        left.elements += right.elements
    }

    /// Determines the difference between two colors.
    /// - Parameters:
    ///   - left: The first color to subtract
    ///   - right: The second color to subtract
    /// - Returns: The difference between two colors
    public static func -(left: Color, right: Color) -> Color {
        Color(left.elements - right.elements)
    }

    public static func -=(left: inout Color, right: Color) {
        left.elements -= right.elements
    }

    /// Scale a color by the given value.
    /// - Parameters:
    ///   - left: The color to scale
    ///   - s: The amount by which to scale the color
    /// - Returns: The scaled color
    public static func *(left: Color, s: Float) -> Color {
        Color(left.elements * s)
    }

    public static func *(s: Float, right: Color) -> Color {
        Color(right.elements * s)
    }

    public static func *(left: Color, right: Color) -> Color {
        Color(left.elements * right.elements)
    }

    public static func *=(left: inout Color, right: Float) {
        left.elements *= right
    }

    public static func /(left: Color, s: Float) -> Color {
        Color(left.elements / s)
    }
}

extension Color {
    /// Modify a value from the gamma space to the linear space.
    /// - Parameter value: The value in gamma space
    /// - Returns: The value in linear space
    public static func gammaToLinearSpace(value: Float) -> Float {
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt

        if (value <= 0.0) {
            return 0.0
        } else if (value <= 0.04045) {
            return value / 12.92
        } else if (value < 1.0) {
            return pow((value + 0.055) / 1.055, 2.4)
        } else {
            return pow(value, 2.4)
        }
    }

    /// Modify a value from the linear space to the gamma space.
    /// - Parameter value: The value in linear space
    /// - Returns: The value in gamma space
    public static func linearToGammaSpace(value: Float) -> Float {
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_framebuffer_sRGB.txt
        // https://www.khronos.org/registry/OpenGL/extensions/EXT/EXT_texture_sRGB_decode.txt

        if (value <= 0.0) {
            return 0.0
        } else if (value < 0.0031308) {
            return 12.92 * value
        } else if (value < 1.0) {
            return 1.055 * pow(value, 0.41666) - 0.055
        } else {
            return pow(value, 0.41666)
        }
    }

    /// Determines whether the specified colors are equals.
    /// - Parameters:
    ///   - left: The first color to compare
    ///   - right: The second color to compare
    /// - Returns: True if the specified colors are equals, false otherwise
    public static func equals(left: Color, right: Color) -> Bool {
        MathUtil.equals(left.r, right.r) &&
                MathUtil.equals(left.g, right.g) &&
                MathUtil.equals(left.b, right.b) &&
                MathUtil.equals(left.a, right.a)
    }

    ///
    /// Performs a linear interpolation between two color.
    /// - Parameters:
    ///   - start: The first color
    ///   - end: The second color
    ///   - t: The blend amount where 0 returns start and 1 end
    /// - Returns: The result of linear blending between two color
    public static func lerp(start: Color, end: Color, t: Float) -> Color {
        Color(mix(start.elements, end.elements, t: t))
    }

    /// Linearly interpolates between colors a and b by t.
    public static func lerpUnclamped(a: Color, b: Color, t: Float) -> Color {
        Color(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t)
    }

    internal func rgbMultiplied(_ multiplier: Float) -> Color {
        Color(r * multiplier, g * multiplier, b * multiplier, a)
    }

    internal func alphaMultiplied(_ multiplier: Float) -> Color {
        Color(r, g, b, a * multiplier)
    }

    internal func rgbMultiplied(_ multiplier: Color) -> Color {
        Color(r * multiplier.r, g * multiplier.g, b * multiplier.b, a)
    }
}

extension Color {
    /// Set the value of this color.
    /// - Parameters:
    ///   - r: The red component of the color
    ///   - g: The green component of the color
    ///   - b: The blue component of the color
    ///   - a: The alpha component of the color
    /// - Returns: This color.
    mutating func set(r: Float, g: Float, b: Float, a: Float) -> Color {
        elements = [r, g, b, a]
        return self
    }

    /// Determines the sum of this color and the specified color.
    /// - Parameter color: The specified color
    /// - Returns: This color
    public mutating func add(color: Color) -> Color {
        elements += color.elements

        return self
    }

    /// Scale this color by the given value.
    /// - Parameter s: The amount by which to scale the color
    /// - Returns: This color
    public mutating func scale(s: Float) -> Color {
        elements *= s

        return self
    }

    /// Modify components (r, g, b) of this color from gamma space to linear space.
    /// - Returns: The color in linear space
    public func toLinear() -> Color {
        Color(Color.gammaToLinearSpace(value: r),
                Color.gammaToLinearSpace(value: g),
                Color.gammaToLinearSpace(value: b), a)
    }

    /// Modify components (r, g, b) of this color from linear space to gamma space.
    /// - Returns: The color in gamma space
    public func toGamma() -> Color {
        Color(Color.linearToGammaSpace(value: r),
                Color.linearToGammaSpace(value: g),
                Color.linearToGammaSpace(value: b), a)
    }

    ///
    /// Gets the brightness.
    /// - Returns: The Hue-Saturation-Brightness (HSB) saturation for this
    public func getBrightness() -> Float {
        var max = r
        var min = r
        if (g > max) {
            max = g
        }
        if (b > max) {
            max = b
        }

        if (g < min) {
            min = g
        }
        if (b < min) {
            min = b
        }

        return (max + min) / 2
    }

    public static func rgbToHSV(rgbColor: Color, H: inout Float, S: inout Float, V: inout Float) {
        if (Double(rgbColor.b) > Double(rgbColor.g)) && (Double(rgbColor.b) > Double(rgbColor.r)) {
            Color.rgbToHSVHelper(offset: 4, dominantcolor: rgbColor.b, colorone: rgbColor.r,
                    colortwo: rgbColor.g, H: &H, S: &S, V: &V)
        } else if Double(rgbColor.g) > Double(rgbColor.r) {
            Color.rgbToHSVHelper(offset: 2, dominantcolor: rgbColor.g, colorone: rgbColor.b,
                    colortwo: rgbColor.r, H: &H, S: &S, V: &V)
        } else {
            Color.rgbToHSVHelper(offset: 0.0, dominantcolor: rgbColor.r, colorone: rgbColor.g,
                    colortwo: rgbColor.b, H: &H, S: &S, V: &V)
        }
    }

    private static func rgbToHSVHelper(
            offset: Float,
            dominantcolor: Float,
            colorone: Float,
            colortwo: Float,
            H: inout Float,
            S: inout Float,
            V: inout Float) {
        V = dominantcolor
        if (Double(V) != 0.0) {
            let num1 = Double(colorone) <= Double(colortwo) ? colorone : colortwo
            let num2 = V - num1
            if (Double(num2) != 0.0) {
                S = num2 / V
                H = offset + (colorone - colortwo) / num2
            } else {
                S = 0.0
                H = offset + (colorone - colortwo)
            }
            H /= 6
            if (Double(H) >= 0.0) {
                return
            }
            H += 1
        } else {
            S = 0.0
            H = 0.0
        }
    }

    /// Creates an RGB colour from HSV input.
    /// - Parameters:
    ///   - H: Hue [0..1].
    ///   - S: Saturation [0..1].
    ///   - V: Brightness value [0..1].
    ///   - hdr: Output HDR colours. If true, the returned colour will not be clamped to [0..1].
    /// - Returns: An opaque colour with HSV matching the input.
    public static func hsvToRGB(_ H: Float, _ S: Float, _ V: Float, hdr: Bool = true) -> Color {
        var white = Color.white
        if (Double(S) == 0.0) {
            white.r = V
            white.g = V
            white.b = V
        } else if (Double(V) == 0.0) {
            white.r = 0.0
            white.g = 0.0
            white.b = 0.0
        } else {
            white.r = 0.0
            white.g = 0.0
            white.b = 0.0
            let num1 = S
            let num2 = V
            let f: Float = H * 6
            let num3: Int = Int(MathUtil.floor(f))
            let num4 = f - Float(num3)
            let num5 = num2 * (1 - num1)
            let num6 = num2 * Float(1.0 - Double(num1) * Double(num4))
            let num7 = num2 * Float(1.0 - Double(num1) * (1.0 - Double(num4)))
            switch (num3) {
            case -1:
                white.r = num2
                white.g = num5
                white.b = num6
                break
            case 0:
                white.r = num2
                white.g = num7
                white.b = num5
                break
            case 1:
                white.r = num6
                white.g = num2
                white.b = num5
                break
            case 2:
                white.r = num5
                white.g = num2
                white.b = num7
                break
            case 3:
                white.r = num5
                white.g = num6
                white.b = num2
                break
            case 4:
                white.r = num7
                white.g = num5
                white.b = num2
                break
            case 5:
                white.r = num2
                white.g = num5
                white.b = num6
                break
            case 6:
                white.r = num2
                white.g = num7
                white.b = num5
                break
            default:
                break
            }
            if (!hdr) {
                white.r = MathUtil.clamp(value: white.r, min: 0.0, max: 1)
                white.g = MathUtil.clamp(value: white.g, min: 0.0, max: 1)
                white.b = MathUtil.clamp(value: white.b, min: 0.0, max: 1)
            }
        }
        return white
    }
}

extension Color: Equatable {
}

extension Color: Codable {
}
