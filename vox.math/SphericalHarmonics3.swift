//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Use SH3 to represent irradiance environment maps efficiently, allowing for interactive rendering of diffuse objects under distant illumination.
/// - Remark:
/// https://graphics.stanford.edu/papers/envmap/envmap.pdf
/// http://www.ppsloan.org/publications/StupidSH36.pdf
/// https://google.github.io/filament/Filament.md.html#annex/sphericalharmonics
public struct SphericalHarmonics3 {
    /// The coefficients of SphericalHarmonics3.
    public var coefficients: [Float] = [Float](repeating: 0, count: 27)

    public init() {
    }

    /// Scale the coefficients.
    /// - Parameters:
    ///   - sh: The sh
    ///   - s: The amount by which to scale the SphericalHarmonics3
    public static func *=(sh: inout SphericalHarmonics3, s: Float) {
        sh.coefficients[0] *= s
        sh.coefficients[1] *= s
        sh.coefficients[2] *= s
        sh.coefficients[3] *= s
        sh.coefficients[4] *= s
        sh.coefficients[5] *= s
        sh.coefficients[6] *= s
        sh.coefficients[7] *= s
        sh.coefficients[8] *= s
        sh.coefficients[9] *= s
        sh.coefficients[10] *= s
        sh.coefficients[11] *= s
        sh.coefficients[12] *= s
        sh.coefficients[13] *= s
        sh.coefficients[14] *= s
        sh.coefficients[15] *= s
        sh.coefficients[16] *= s
        sh.coefficients[17] *= s
        sh.coefficients[18] *= s
        sh.coefficients[19] *= s
        sh.coefficients[20] *= s
        sh.coefficients[21] *= s
        sh.coefficients[22] *= s
        sh.coefficients[23] *= s
        sh.coefficients[24] *= s
        sh.coefficients[25] *= s
        sh.coefficients[26] *= s
    }

    /// Add light to SphericalHarmonics3.
    /// - Parameters:
    ///   - direction: Light direction
    ///   - color: Light color
    ///   - deltaSolidAngle: The delta solid angle of the light
    public mutating func addLight(direction: Vector3, color: Color, deltaSolidAngle: Float) {
        /**
         * Implements `EvalSHBasis` from [Projection from Cube maps] in http://www.ppsloan.org/publications/StupidSH36.pdf.
         *
         * Basis constants
         * 0: Math.sqrt(1/(4 * Math.PI))
         *
         * 1: -Math.sqrt(3 / (4 * Math.PI))
         * 2: Math.sqrt(3 / (4 * Math.PI))
         * 3: -Math.sqrt(3 / (4 * Math.PI))
         *
         * 4: Math.sqrt(15 / (4 * Math.PI))
         * 5: -Math.sqrt(15 / (4 * Math.PI))
         * 6: Math.sqrt(5 / (16 * Math.PI))
         * 7: -Math.sqrt(15 / (4 * Math.PI)）
         * 8: Math.sqrt(15 / (16 * Math.PI))
         */

        let color = color * deltaSolidAngle
        let x = direction.x
        let y = direction.y
        let z = direction.z
        let r = color.r
        let g = color.g
        let b = color.b

        let bv0: Float = 0.282095 // basis0 = 0.886227
        let bv1 = -0.488603 * y // basis1 = -0.488603
        let bv2 = 0.488603 * z // basis2 = 0.488603
        let bv3 = -0.488603 * x // basis3 = -0.488603
        let bv4 = 1.092548 * (x * y) // basis4 = 1.092548
        let bv5 = -1.092548 * (y * z) // basis5 = -1.092548
        let bv6 = 0.315392 * (3 * z * z - 1) // basis6 = 0.315392
        let bv7 = -1.092548 * (x * z) // basis7 = -1.092548
        let bv8 = 0.546274 * (x * x - y * y) // basis8 = 0.546274

        coefficients[0] += r * bv0
        coefficients[1] += g * bv0
        coefficients[2] += b * bv0

        coefficients[3] += r * bv1
        coefficients[4] += g * bv1
        coefficients[5] += b * bv1
        coefficients[6] += r * bv2
        coefficients[7] += g * bv2
        coefficients[8] += b * bv2
        coefficients[9] += r * bv3
        coefficients[10] += g * bv3
        coefficients[11] += b * bv3

        coefficients[12] += r * bv4
        coefficients[13] += g * bv4
        coefficients[14] += b * bv4
        coefficients[15] += r * bv5
        coefficients[16] += g * bv5
        coefficients[17] += b * bv5
        coefficients[18] += r * bv6
        coefficients[19] += g * bv6
        coefficients[20] += b * bv6
        coefficients[21] += r * bv7
        coefficients[22] += g * bv7
        coefficients[23] += b * bv7
        coefficients[24] += r * bv8
        coefficients[25] += g * bv8
        coefficients[26] += b * bv8
    }

    /// Set the value of this spherical harmonics by an array.
    /// - Parameters:
    ///   - array: The array
    ///   - offset: The start offset of the array
    public mutating func set(array: [Float], offset: Int = 0) {
        coefficients[0] = array[offset]
        coefficients[1] = array[1 + offset]
        coefficients[2] = array[2 + offset]
        coefficients[3] = array[3 + offset]
        coefficients[4] = array[4 + offset]
        coefficients[5] = array[5 + offset]
        coefficients[6] = array[6 + offset]
        coefficients[7] = array[7 + offset]
        coefficients[8] = array[8 + offset]
        coefficients[9] = array[9 + offset]
        coefficients[10] = array[10 + offset]
        coefficients[11] = array[11 + offset]
        coefficients[12] = array[12 + offset]
        coefficients[13] = array[13 + offset]
        coefficients[14] = array[14 + offset]
        coefficients[15] = array[15 + offset]
        coefficients[16] = array[16 + offset]
        coefficients[17] = array[17 + offset]
        coefficients[18] = array[18 + offset]
        coefficients[19] = array[19 + offset]
        coefficients[20] = array[20 + offset]
        coefficients[21] = array[21 + offset]
        coefficients[22] = array[22 + offset]
        coefficients[23] = array[23 + offset]
        coefficients[24] = array[24 + offset]
        coefficients[25] = array[25 + offset]
        coefficients[26] = array[26 + offset]
    }

    /// Evaluates the color for the specified direction.
    /// - Parameters:
    ///   - direction: Specified direction
    /// - Returns: Out color
    public func evaluate(direction: Vector3) -> Color {
        /**
         * Equations based on data from: http://ppsloan.org/publications/StupidSH36.pdf
         *
         *
         * Basis constants
         * 0: Math.sqrt(1/(4 * Math.PI))
         *
         * 1: -Math.sqrt(3 / (4 * Math.PI))
         * 2: Math.sqrt(3 / (4 * Math.PI))
         * 3: -Math.sqrt(3 / (4 * Math.PI))
         *
         * 4: Math.sqrt(15 / (4 * Math.PI)）
         * 5: -Math.sqrt(15 / (4 * Math.PI))
         * 6: Math.sqrt(5 / (16 * Math.PI)）
         * 7: -Math.sqrt(15 / (4 * Math.PI)）
         * 8: Math.sqrt(15 / (16 * Math.PI)）
         *
         *
         * Convolution kernel
         * 0: Math.PI
         * 1: (2 * Math.PI) / 3
         * 2: Math.PI / 4
         */

        let coe = coefficients
        let x = direction.x
        let y = direction.y
        let z = direction.z

        let bv0: Float = 0.886227 // kernel0 * basis0 = 0.886227
        let bv1 = -1.023327 * y // kernel1 * basis1 = -1.023327
        let bv2 = 1.023327 * z // kernel1 * basis2 = 1.023327
        let bv3 = -1.023327 * x // kernel1 * basis3 = -1.023327
        let bv4 = 0.858086 * y * x // kernel2 * basis4 = 0.858086
        let bv5 = -0.858086 * y * z // kernel2 * basis5 = -0.858086
        let bv6 = 0.247708 * (3 * z * z - 1) // kernel2 * basis6 = 0.247708
        let bv7 = -0.858086 * z * x // kernel2 * basis7 = -0.858086
        let bv8 = 0.429042 * (x * x - y * y) // kernel2 * basis8 = 0.429042

        // l0
        var r = coe[0] * bv0
        var g = coe[1] * bv0
        var b = coe[2] * bv0

        // l1
        r += coe[3] * bv1 + coe[6] * bv2 + coe[9] * bv3
        g += coe[4] * bv1 + coe[7] * bv2 + coe[10] * bv3
        b += coe[5] * bv1 + coe[8] * bv2 + coe[11] * bv3

        // l2
        r += coe[12] * bv4 + coe[15] * bv5 + coe[18] * bv6 + coe[21] * bv7 + coe[24] * bv8
        g += coe[13] * bv4 + coe[16] * bv5 + coe[19] * bv6 + coe[22] * bv7 + coe[25] * bv8
        b += coe[14] * bv4 + coe[17] * bv5 + coe[20] * bv6 + coe[23] * bv7 + coe[26] * bv8

        return Color(r, g, b, 1.0)
    }

    /// Clone the value of this spherical harmonics to an array.
    /// - Parameters:
    ///   - out: The array
    ///   - outOffset: The start offset of the array
    public func toArray(out: inout [Float], outOffset: Int = 0) {
        let s = coefficients

        out[0 + outOffset] = s[0]
        out[1 + outOffset] = s[1]
        out[2 + outOffset] = s[2]

        out[3 + outOffset] = s[3]
        out[4 + outOffset] = s[4]
        out[5 + outOffset] = s[5]
        out[6 + outOffset] = s[6]
        out[7 + outOffset] = s[7]
        out[8 + outOffset] = s[8]
        out[9 + outOffset] = s[9]
        out[10 + outOffset] = s[10]
        out[11 + outOffset] = s[11]

        out[12 + outOffset] = s[12]
        out[13 + outOffset] = s[13]
        out[14 + outOffset] = s[14]
        out[15 + outOffset] = s[15]
        out[16 + outOffset] = s[16]
        out[17 + outOffset] = s[17]
        out[18 + outOffset] = s[18]
        out[19 + outOffset] = s[19]
        out[20 + outOffset] = s[20]
        out[21 + outOffset] = s[21]
        out[22 + outOffset] = s[22]
        out[23 + outOffset] = s[23]
        out[24 + outOffset] = s[24]
        out[25 + outOffset] = s[25]
        out[26 + outOffset] = s[26]
    }
}
