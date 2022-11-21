//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Describes a color in the from of RGBA (in order: R, G, B, A).
public struct Color {
    /// The color component of the color, 0~1.
    var elements: SIMD4<Float>

    /// The red component of the color, 0~1.
    public var r: Float {
        get {
            elements.x
        }
    }
    /// The green component of the color, 0~1.
    public var g: Float {
        get {
            elements.y
        }
    }
    /// The blue component of the color, 0~1.
    public var b: Float {
        get {
            elements.z
        }
    }
    /// The alpha component of the color, 0~1.
    public var a: Float {
        get {
            elements.w
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

    public static func *=(left: inout Color, right: Float) {
        left.elements *= right
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
}

extension Color {
    /// Set the value of this color.
    /// - Parameters:
    ///   - r: The red component of the color
    ///   - g: The green component of the color
    ///   - b: The blue component of the color
    ///   - a: The alpha component of the color
    /// - Returns: This color.
    public mutating func set(r: Float, g: Float, b: Float, a: Float) -> Color {
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
                Color.gammaToLinearSpace(value: b))
    }

    /// Modify components (r, g, b) of this color from linear space to gamma space.
    /// - Returns: The color in gamma space
    public func toGamma() -> Color {
        Color(Color.linearToGammaSpace(value: r),
                Color.linearToGammaSpace(value: g),
                Color.linearToGammaSpace(value: b))
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
}
