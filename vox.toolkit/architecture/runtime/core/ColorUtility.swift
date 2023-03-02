//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Hue (0,360), Saturation (0,1), Value (0,1)
struct HSVColor {
    public var h: Float, s: Float, v: Float

    public init(_ h: Float, _ s: Float, _ v: Float) {
        self.h = h
        self.s = s
        self.v = v
    }

    /// Wikipedia colors are from 0-100 %, so this constructor includes and S, V normalizes the values.
    /// modifier value that affects saturation and value, making it useful for any SV value range.
    public init(_ h: Float, _ s: Float, _ v: Float, sv_modifier: Float) {
        self.h = h
        self.s = s * sv_modifier
        self.v = v * sv_modifier
    }

    public static func FromRGB(_ col: Color) -> HSVColor {
        ColorUtility.RGBtoHSV(col)
    }

    public func SqrDistance(InColor: HSVColor) -> Float {
        (InColor.h / 360 - h / 360) + (InColor.s - s) + (InColor.v - v)
    }
}

extension HSVColor: CustomStringConvertible {
    public var description: String {
        "( \(h), \(s), \(v) )"
    }
}

/// <summary>
/// XYZ color
/// <remarks>http://www.easyrgb.com/index.php?X=MATH&H=07#text7</remarks>
/// </summary>
struct XYZColor {
    public var x: Float, y: Float, z: Float

    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func FromRGB(_ col: Color) -> XYZColor {
        ColorUtility.RGBToXYZ(col)
    }

    public static func FromRGB(_ R: Float, _ G: Float, _ B: Float) -> XYZColor {
        ColorUtility.RGBToXYZ(R, G, B)
    }
}

extension XYZColor: CustomStringConvertible {
    public var description: String {
        "( \(x), \(y), \(z) )"
    }
}

/// CIE_Lab* color
struct CIELabColor {
    public var L: Float, a: Float, b: Float

    public init(_ L: Float, _ a: Float, _ b: Float) {
        self.L = L
        self.a = a
        self.b = b
    }

    public static func FromXYZ(_ xyz: XYZColor) -> CIELabColor {
        ColorUtility.XYZToCIE_Lab(xyz)
    }

    public static func FromRGB(_ col: Color) -> CIELabColor {
        let xyz = XYZColor.FromRGB(col)

        return ColorUtility.XYZToCIE_Lab(xyz)
    }
}

extension CIELabColor: CustomStringConvertible {
    public var description: String {
        "( \(L), \(a), \(b) )"
    }
}

/// <summary>
/// Conversion methods for RGB, HSV, XYZ, CIE-Lab
/// </summary>
class ColorUtility {
    /// Compare float values within Epsilon distance.
    static func approx(_ lhs: Float, _ rhs: Float) -> Bool {
        return MathUtil.abs(lhs - rhs) < Float.leastNonzeroMagnitude
    }

    public static func GetColor(_ vec: Vector3) -> Color {
        var vec = vec
        _ = vec.normalize()
        return Color(MathUtil.abs(vec.x), MathUtil.abs(vec.y), MathUtil.abs(vec.z), 1)
    }

    /// Convert RGBA color to XYZ
    public static func RGBToXYZ(_ col: Color) -> XYZColor {
        return RGBToXYZ(col.r, col.g, col.b)
    }

    public static func RGBToXYZ(_ r: Float, _ g: Float, _ b: Float) -> XYZColor {
        var r = r
        var g = g
        var b = b
        if (r > 0.04045) {
            r = MathUtil.pow(((r + 0.055) / 1.055), 2.4)
        } else {
            r = r / 12.92
        }

        if (g > 0.04045) {
            g = MathUtil.pow(((g + 0.055) / 1.055), 2.4)
        } else {
            g = g / 12.92
        }
        if (b > 0.04045) {
            b = MathUtil.pow(((b + 0.055) / 1.055), 2.4)
        } else {
            b = b / 12.92
        }
        r = r * 100
        g = g * 100
        b = b * 100

        // Observer. = 2°, Illuminant = D65
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505

        return XYZColor(x, y, z)
    }

    /// Convert XYZ color to CIE_Lab
    public static func XYZToCIE_Lab(_ xyz: XYZColor) -> CIELabColor {
        var var_X = xyz.x / 95.047           // ref_X =  95.047   Observer= 2°, Illuminant= D65
        var var_Y = xyz.y / 100.000          // ref_Y = 100.000
        var var_Z = xyz.z / 108.883          // ref_Z = 108.883

        if (var_X > 0.008856) {
            var_X = MathUtil.pow(var_X, (1 / 3.0))
        } else {
            var_X = (7.787 * var_X) + (16.0 / 116.0)
        }
        if (var_Y > 0.008856) {
            var_Y = MathUtil.pow(var_Y, (1 / 3.0))
        } else {
            var_Y = (7.787 * var_Y) + (16.0 / 116.0)
        }
        if (var_Z > 0.008856) {
            var_Z = MathUtil.pow(var_Z, (1 / 3.0))
        } else {
            var_Z = (7.787 * var_Z) + (16.0 / 116.0)
        }
        let L = (116 * var_Y) - 16
        let a = 500 * (var_X - var_Y)
        let b = 200 * (var_Y - var_Z)

        return CIELabColor(L, a, b)
    }

    /// Calculate the euclidean distance between two Cie-Lab colors (DeltaE).
    /// http://www.easyrgb.com/index.php?X=DELT&H=03#text3
    public static func DeltaE(_ lhs: CIELabColor, _ rhs: CIELabColor) -> Float {
        return MathUtil.sqrt(
                MathUtil.pow((lhs.L - rhs.L), 2) +
                        MathUtil.pow((lhs.a - rhs.a), 2) +
                        MathUtil.pow((lhs.b - rhs.b), 2))
    }

    /// Convert HSV to RGB.
    ///  http://www.cs.rit.edu/~ncs/color/t_convert.html
    /// r,g,b values are from 0 to 1
    /// h = [0,360], s = [0,1], v = [0,1]
    /// if s == 0, then h = -1 (undefined)
    public static func HSVtoRGB(_ hsv: HSVColor) -> Color {
        return HSVtoRGB(hsv.h, hsv.s, hsv.v)
    }

    /// Convert HSV color to RGB.
    public static func HSVtoRGB(_ h: Float, _ s: Float, _ v: Float) -> Color {
        var h = h
        var r: Float, g: Float, b: Float
        var i: Int
        var f: Float, p: Float, q: Float, t: Float
        if (s == 0) {
            // achromatic (grey)
            return Color(v, v, v, 1)
        }
        h /= 60            // sector 0 to 5
        i = Int(MathUtil.floor(h))
        f = h - Float(i)          // factorial part of h
        p = v * (1 - s)
        q = v * (1 - s * f)
        t = v * (1 - s * (1 - f))

        switch (i) {
        case 0:
            r = v
            g = t
            b = p
            break
        case 1:
            r = q
            g = v
            b = p
            break
        case 2:
            r = p
            g = v
            b = t
            break
        case 3:
            r = p
            g = q
            b = v
            break
        case 4:
            r = t
            g = p
            b = v
            break
        default:        // case 5:
            r = v
            g = p
            b = q
            break
        }

        return Color(r, g, b, 1)
    }

    /// http://www.cs.rit.edu/~ncs/color/t_convert.html
    /// r,g,b values are from 0 to 1
    /// h = [0,360], s = [0,1], v = [0,1]
    ///     if s == 0, then h = -1 (undefined)
    public static func RGBtoHSV(_ color: Color) -> HSVColor {
        var h: Float, s: Float, v: Float
        let r = color.r, b = color.b, g = color.g

        var min: Float, max: Float, delta: Float
        min = MathUtil.min(MathUtil.min(r, g), b)
        max = MathUtil.max(MathUtil.max(r, g), b)

        v = max                // v

        delta = max - min

        if (max != 0) {
            s = delta / max        // s
        } else {
            // r = g = b = 0        // s = 0, v is undefined
            s = 0
            h = 0
            return HSVColor(h, s, v)
        }

        if (approx(r, max)) {
            h = (g - b) / delta        // between yellow & magenta
            if h.isNaN {
                h = 0
            }
        } else if (approx(g, max)) {
            h = 2 + (b - r) / delta   // between cyan & yellow
        } else {
            h = 4 + (r - g) / delta   // between magenta & cyan
        }

        h *= 60                  // degrees

        if (h < 0) {
            h += 360
        }

        return HSVColor(h, s, v)
    }

    /// Get human readable name from a Color.
    public static func GetColorName(_ InColor: Color) -> String {
        let lab = CIELabColor.FromRGB(InColor)

        var name = "Unknown"
        var diff = Float.infinity

        for kvp in ColorNameLookup {
            let dist = MathUtil.abs(DeltaE(lab, kvp.value))

            if (dist < diff) {
                diff = dist
                name = kvp.key
            }
        }

        return name
    }

    static func CIELabFromRGB(_ R: Float, _ G: Float, _ B: Float, _ Scale: Float) -> CIELabColor {
        let inv_scale = 1 / Scale
        let xyz = XYZColor.FromRGB(R * inv_scale, G * inv_scale, B * inv_scale)

        return CIELabColor.FromXYZ(xyz)
    }

    /// http://en.wikipedia.org/wiki/List_of_colors:_A%E2%80%93F
    static let ColorNameLookup: [String: CIELabColor] = [
        "Acid Green": CIELabFromRGB(69, 75, 10, 100),
        "Aero": CIELabFromRGB(49, 73, 91, 100),
        "Aero Blue": CIELabFromRGB(79, 100, 90, 100),
        "African Violet": CIELabFromRGB(70, 52, 75, 100),
        "Air Force Blue (RAF)": CIELabFromRGB(36, 54, 66, 100),
        "Air Force Blue (USAF)": CIELabFromRGB(0, 19, 56, 100),
        "Air Superiority Blue": CIELabFromRGB(45, 63, 76, 100),
        "Alabama Crimson": CIELabFromRGB(69, 0, 16, 100),
        "Alice Blue": CIELabFromRGB(94, 97, 100, 100),
        "Alizarin Crimson": CIELabFromRGB(89, 15, 21, 100),
        "Alloy Orange": CIELabFromRGB(77, 38, 6, 100),
        "Almond": CIELabFromRGB(94, 87, 80, 100),
        "Amaranth": CIELabFromRGB(90, 17, 31, 100),
        "Amaranth Deep Purple": CIELabFromRGB(67, 15, 31, 100),
        "Amaranth Pink": CIELabFromRGB(95, 61, 73, 100),
        "Amaranth Purple": CIELabFromRGB(67, 15, 31, 100),
        "Amaranth Red": CIELabFromRGB(83, 13, 18, 100),
        "Amazon": CIELabFromRGB(23, 48, 34, 100),
        "Amber": CIELabFromRGB(100, 75, 0, 100),
        "Amber (SAE/ECE)": CIELabFromRGB(100, 49, 0, 100),
        "American Rose": CIELabFromRGB(100, 1, 24, 100),
        "Amethyst": CIELabFromRGB(60, 40, 80, 100),
        "Android Green": CIELabFromRGB(64, 78, 22, 100),
        "Anti-Flash White": CIELabFromRGB(95, 95, 96, 100),
        "Antique Brass": CIELabFromRGB(80, 58, 46, 100),
        "Antique Bronze": CIELabFromRGB(40, 36, 12, 100),
        "Antique Fuchsia": CIELabFromRGB(57, 36, 51, 100),
        "Antique Ruby": CIELabFromRGB(52, 11, 18, 100),
        "Antique White": CIELabFromRGB(98, 92, 84, 100),
        "Ao (English)": CIELabFromRGB(0, 50, 0, 100),
        "Apple Green": CIELabFromRGB(55, 71, 0, 100),
        "Apricot": CIELabFromRGB(98, 81, 69, 100),
        "Aqua": CIELabFromRGB(0, 100, 100, 100),
        "Aquamarine": CIELabFromRGB(50, 100, 83, 100),
        "Army Green": CIELabFromRGB(29, 33, 13, 100),
        "Arsenic": CIELabFromRGB(23, 27, 29, 100),
        "Artichoke": CIELabFromRGB(56, 59, 47, 100),
        "Arylide Yellow": CIELabFromRGB(91, 84, 42, 100),
        "Ash Grey": CIELabFromRGB(70, 75, 71, 100),
        "Asparagus": CIELabFromRGB(53, 66, 42, 100),
        "Atomic Tangerine": CIELabFromRGB(100, 60, 40, 100),
        "Auburn": CIELabFromRGB(65, 16, 16, 100),
        "Aureolin": CIELabFromRGB(99, 93, 0, 100),
        "AuroMetalSaurus": CIELabFromRGB(43, 50, 50, 100),
        "Avocado": CIELabFromRGB(34, 51, 1, 100),
        "Azure": CIELabFromRGB(0, 50, 100, 100),
        "Azure (Web Color)": CIELabFromRGB(94, 100, 100, 100),
        "Azure Mist": CIELabFromRGB(94, 100, 100, 100),
        "Azureish White": CIELabFromRGB(86, 91, 96, 100),
        "Baby Blue": CIELabFromRGB(54, 81, 94, 100),
        "Baby Blue Eyes": CIELabFromRGB(63, 79, 95, 100),
        "Baby Pink": CIELabFromRGB(96, 76, 76, 100),
        "Baby Powder": CIELabFromRGB(100, 100, 98, 100),
        "Baker-Miller Pink": CIELabFromRGB(100, 57, 69, 100),
        "Ball Blue": CIELabFromRGB(13, 67, 80, 100),
        "Banana Mania": CIELabFromRGB(98, 91, 71, 100),
        "Banana Yellow": CIELabFromRGB(100, 88, 21, 100),
        "Bangladesh Green": CIELabFromRGB(0, 42, 31, 100),
        "Barbie Pink": CIELabFromRGB(88, 13, 54, 100),
        "Barn Red": CIELabFromRGB(49, 4, 1, 100),
        "Battleship Grey": CIELabFromRGB(52, 52, 51, 100),
        "Bazaar": CIELabFromRGB(60, 47, 48, 100),
        "Beau Blue": CIELabFromRGB(74, 83, 90, 100),
        "Beaver": CIELabFromRGB(62, 51, 44, 100),
        "Beige": CIELabFromRGB(96, 96, 86, 100),
        "B'dazzled Blue": CIELabFromRGB(18, 35, 58, 100),
        "Big Dip O’ruby": CIELabFromRGB(61, 15, 26, 100),
        "Bisque": CIELabFromRGB(100, 89, 77, 100),
        "Bistre": CIELabFromRGB(24, 17, 12, 100),
        "Bistre Brown": CIELabFromRGB(59, 44, 9, 100),
        "Bitter Lemon": CIELabFromRGB(79, 88, 5, 100),
        "Bitter Lime": CIELabFromRGB(75, 100, 0, 100),
        "Bittersweet": CIELabFromRGB(100, 44, 37, 100),
        "Bittersweet Shimmer": CIELabFromRGB(75, 31, 32, 100),
        "Black": CIELabFromRGB(0, 0, 0, 100),
        "Black Bean": CIELabFromRGB(24, 5, 1, 100),
        "Black Leather Jacket": CIELabFromRGB(15, 21, 16, 100),
        "Black Olive": CIELabFromRGB(23, 24, 21, 100),
        "Blanched Almond": CIELabFromRGB(100, 92, 80, 100),
        "Blast-Off Bronze": CIELabFromRGB(65, 44, 39, 100),
        "Bleu De France": CIELabFromRGB(19, 55, 91, 100),
        "Blizzard Blue": CIELabFromRGB(67, 90, 93, 100),
        "Blond": CIELabFromRGB(98, 94, 75, 100),
        "Blue": CIELabFromRGB(0, 0, 100, 100),
        "Blue (Crayola)": CIELabFromRGB(12, 46, 100, 100),
        "Blue (Munsell)": CIELabFromRGB(0, 58, 69, 100),
        "Blue (NCS)": CIELabFromRGB(0, 53, 74, 100),
        "Blue (Pantone)": CIELabFromRGB(0, 9, 66, 100),
        "Blue (Pigment)": CIELabFromRGB(20, 20, 60, 100),
        "Blue (RYB)": CIELabFromRGB(1, 28, 100, 100),
        "Blue Bell": CIELabFromRGB(64, 64, 82, 100),
        "Blue-Gray": CIELabFromRGB(40, 60, 80, 100),
        "Blue-Green": CIELabFromRGB(5, 60, 73, 100),
        "Blue Lagoon": CIELabFromRGB(37, 58, 63, 100),
        "Blue-Magenta Violet": CIELabFromRGB(33, 21, 57, 100),
        "Blue Sapphire": CIELabFromRGB(7, 38, 50, 100),
        "Blue-Violet": CIELabFromRGB(54, 17, 89, 100),
        "Blue Yonder": CIELabFromRGB(31, 45, 65, 100),
        "Blueberry": CIELabFromRGB(31, 53, 97, 100),
        "Bluebonnet": CIELabFromRGB(11, 11, 94, 100),
        "Blush": CIELabFromRGB(87, 36, 51, 100),
        "Bole": CIELabFromRGB(47, 27, 23, 100),
        "Bondi Blue": CIELabFromRGB(0, 58, 71, 100),
        "Bone": CIELabFromRGB(89, 85, 79, 100),
        "Boston University Red": CIELabFromRGB(80, 0, 0, 100),
        "Bottle Green": CIELabFromRGB(0, 42, 31, 100),
        "Boysenberry": CIELabFromRGB(53, 20, 38, 100),
        "Brandeis Blue": CIELabFromRGB(0, 44, 100, 100),
        "Brass": CIELabFromRGB(71, 65, 26, 100),
        "Brick Red": CIELabFromRGB(80, 25, 33, 100),
        "Bright Cerulean": CIELabFromRGB(11, 67, 84, 100),
        "Bright Green": CIELabFromRGB(40, 100, 0, 100),
        "Bright Lavender": CIELabFromRGB(75, 58, 89, 100),
        "Bright Lilac": CIELabFromRGB(85, 57, 94, 100),
        "Bright Maroon": CIELabFromRGB(76, 13, 28, 100),
        "Bright Navy Blue": CIELabFromRGB(10, 45, 82, 100),
        "Bright Pink": CIELabFromRGB(100, 0, 50, 100),
        "Bright Turquoise": CIELabFromRGB(3, 91, 87, 100),
        "Bright Ube": CIELabFromRGB(82, 62, 91, 100),
        "Brilliant Azure": CIELabFromRGB(20, 60, 100, 100),
        "Brilliant Lavender": CIELabFromRGB(96, 73, 100, 100),
        "Brilliant Rose": CIELabFromRGB(100, 33, 64, 100),
        "Brink Pink": CIELabFromRGB(98, 38, 50, 100),
        "British Racing Green": CIELabFromRGB(0, 26, 15, 100),
        "Bronze": CIELabFromRGB(80, 50, 20, 100),
        "Bronze Yellow": CIELabFromRGB(45, 44, 0, 100),
        "Brown (Traditional)": CIELabFromRGB(59, 29, 0, 100),
        "Brown (Web)": CIELabFromRGB(65, 16, 16, 100),
        "Brown-Nose": CIELabFromRGB(42, 27, 14, 100),
        "Brown Yellow": CIELabFromRGB(80, 60, 40, 100),
        "Brunswick Green": CIELabFromRGB(11, 30, 24, 100),
        "Bubble Gum": CIELabFromRGB(100, 76, 80, 100),
        "Bubbles": CIELabFromRGB(91, 100, 100, 100),
        "Buff": CIELabFromRGB(94, 86, 51, 100),
        "Bud Green": CIELabFromRGB(48, 71, 38, 100),
        "Bulgarian Rose": CIELabFromRGB(28, 2, 3, 100),
        "Burgundy": CIELabFromRGB(50, 0, 13, 100),
        "Burlywood": CIELabFromRGB(87, 72, 53, 100),
        "Burnt Orange": CIELabFromRGB(80, 33, 0, 100),
        "Burnt Sienna": CIELabFromRGB(91, 45, 32, 100),
        "Burnt Umber": CIELabFromRGB(54, 20, 14, 100),
        "Byzantine": CIELabFromRGB(74, 20, 64, 100),
        "Byzantium": CIELabFromRGB(44, 16, 39, 100),
        "Cadet": CIELabFromRGB(33, 41, 45, 100),
        "Cadet Blue": CIELabFromRGB(37, 62, 63, 100),
        "Cadet Grey": CIELabFromRGB(57, 64, 69, 100),
        "Cadmium Green": CIELabFromRGB(0, 42, 24, 100),
        "Cadmium Orange": CIELabFromRGB(93, 53, 18, 100),
        "Cadmium Red": CIELabFromRGB(89, 0, 13, 100),
        "Cadmium Yellow": CIELabFromRGB(100, 96, 0, 100),
        "Cafe Au Lait": CIELabFromRGB(65, 48, 36, 100),
        "Cafe Noir": CIELabFromRGB(29, 21, 13, 100),
        "Cal Poly Green": CIELabFromRGB(12, 30, 17, 100),
        "Cambridge Blue": CIELabFromRGB(64, 76, 68, 100),
        "Camel": CIELabFromRGB(76, 60, 42, 100),
        "Cameo Pink": CIELabFromRGB(94, 73, 80, 100),
        "Camouflage Green": CIELabFromRGB(47, 53, 42, 100),
        "Canary Yellow": CIELabFromRGB(100, 94, 0, 100),
        "Candy Apple Red": CIELabFromRGB(100, 3, 0, 100),
        "Candy Pink": CIELabFromRGB(89, 44, 48, 100),
        "Capri": CIELabFromRGB(0, 75, 100, 100),
        "Caput Mortuum": CIELabFromRGB(35, 15, 13, 100),
        "Cardinal": CIELabFromRGB(77, 12, 23, 100),
        "Caribbean Green": CIELabFromRGB(0, 80, 60, 100),
        "Carmine": CIELabFromRGB(59, 0, 9, 100),
        "Carmine (M&P)": CIELabFromRGB(84, 0, 25, 100),
        "Carmine Pink": CIELabFromRGB(92, 30, 26, 100),
        "Carmine Red": CIELabFromRGB(100, 0, 22, 100),
        "Carnation Pink": CIELabFromRGB(100, 65, 79, 100),
        "Carnelian": CIELabFromRGB(70, 11, 11, 100),
        "Carolina Blue": CIELabFromRGB(34, 63, 83, 100),
        "Carrot Orange": CIELabFromRGB(93, 57, 13, 100),
        "Castleton Green": CIELabFromRGB(0, 34, 25, 100),
        "Catalina Blue": CIELabFromRGB(2, 16, 47, 100),
        "Catawba": CIELabFromRGB(44, 21, 26, 100),
        "Cedar Chest": CIELabFromRGB(79, 35, 29, 100),
        "Ceil": CIELabFromRGB(57, 63, 81, 100),
        "Celadon": CIELabFromRGB(67, 88, 69, 100),
        "Celadon Blue": CIELabFromRGB(0, 48, 65, 100),
        "Celadon Green": CIELabFromRGB(18, 52, 49, 100),
        "Celeste": CIELabFromRGB(70, 100, 100, 100),
        "Celestial Blue": CIELabFromRGB(29, 59, 82, 100),
        "Cerise": CIELabFromRGB(87, 19, 39, 100),
        "Cerise Pink": CIELabFromRGB(93, 23, 51, 100),
        "Cerulean": CIELabFromRGB(0, 48, 65, 100),
        "Cerulean Blue": CIELabFromRGB(16, 32, 75, 100),
        "Cerulean Frost": CIELabFromRGB(43, 61, 76, 100),
        "CG Blue": CIELabFromRGB(0, 48, 65, 100),
        "CG Red": CIELabFromRGB(88, 24, 19, 100),
        "Chamoisee": CIELabFromRGB(63, 47, 35, 100),
        "Champagne": CIELabFromRGB(97, 91, 81, 100),
        "Charcoal": CIELabFromRGB(21, 27, 31, 100),
        "Charleston Green": CIELabFromRGB(14, 17, 17, 100),
        "Charm Pink": CIELabFromRGB(90, 56, 67, 100),
        "Chartreuse (Traditional)": CIELabFromRGB(87, 100, 0, 100),
        "Chartreuse (Web)": CIELabFromRGB(50, 100, 0, 100),
        "Cherry": CIELabFromRGB(87, 19, 39, 100),
        "Cherry Blossom Pink": CIELabFromRGB(100, 72, 77, 100),
        "Chestnut": CIELabFromRGB(58, 27, 21, 100),
        "China Pink": CIELabFromRGB(87, 44, 63, 100),
        "China Rose": CIELabFromRGB(66, 32, 43, 100),
        "Chinese Red": CIELabFromRGB(67, 22, 12, 100),
        "Chinese Violet": CIELabFromRGB(52, 38, 53, 100),
        "Chocolate (Traditional)": CIELabFromRGB(48, 25, 0, 100),
        "Chocolate (Web)": CIELabFromRGB(82, 41, 12, 100),
        "Chrome Yellow": CIELabFromRGB(100, 65, 0, 100),
        "Cinereous": CIELabFromRGB(60, 51, 48, 100),
        "Cinnabar": CIELabFromRGB(89, 26, 20, 100),
        "Cinnamon": CIELabFromRGB(82, 41, 12, 100),
        "Citrine": CIELabFromRGB(89, 82, 4, 100),
        "Citron": CIELabFromRGB(62, 66, 12, 100),
        "Claret": CIELabFromRGB(50, 9, 20, 100),
        "Classic Rose": CIELabFromRGB(98, 80, 91, 100),
        "Cobalt Blue": CIELabFromRGB(0, 28, 67, 100),
        "Cocoa Brown": CIELabFromRGB(82, 41, 12, 100),
        "Coconut": CIELabFromRGB(59, 35, 24, 100),
        "Coffee": CIELabFromRGB(44, 31, 22, 100),
        "Columbia Blue": CIELabFromRGB(77, 85, 89, 100),
        "Congo Pink": CIELabFromRGB(97, 51, 47, 100),
        "Cool Black": CIELabFromRGB(0, 18, 39, 100),
        "Cool Grey": CIELabFromRGB(55, 57, 67, 100),
        "Copper": CIELabFromRGB(72, 45, 20, 100),
        "Copper (Crayola)": CIELabFromRGB(85, 54, 40, 100),
        "Copper Penny": CIELabFromRGB(68, 44, 41, 100),
        "Copper Red": CIELabFromRGB(80, 43, 32, 100),
        "Copper Rose": CIELabFromRGB(60, 40, 40, 100),
        "Coquelicot": CIELabFromRGB(100, 22, 0, 100),
        "Coral": CIELabFromRGB(100, 50, 31, 100),
        "Coral Pink": CIELabFromRGB(97, 51, 47, 100),
        "Coral Red": CIELabFromRGB(100, 25, 25, 100),
        "Cordovan": CIELabFromRGB(54, 25, 27, 100),
        "Corn": CIELabFromRGB(98, 93, 36, 100),
        "Cornell Red": CIELabFromRGB(70, 11, 11, 100),
        "Cornflower Blue": CIELabFromRGB(39, 58, 93, 100),
        "Cornsilk": CIELabFromRGB(100, 97, 86, 100),
        "Cosmic Latte": CIELabFromRGB(100, 97, 91, 100),
        "Coyote Brown": CIELabFromRGB(51, 38, 24, 100),
        "Cotton Candy": CIELabFromRGB(100, 74, 85, 100),
        "Cream": CIELabFromRGB(100, 99, 82, 100),
        "Crimson": CIELabFromRGB(86, 8, 24, 100),
        "Crimson Glory": CIELabFromRGB(75, 0, 20, 100),
        "Crimson Red": CIELabFromRGB(60, 0, 0, 100),
        "Cyan": CIELabFromRGB(0, 100, 100, 100),
        "Cyan Azure": CIELabFromRGB(31, 51, 71, 100),
        "Cyan-Blue Azure": CIELabFromRGB(27, 51, 75, 100),
        "Cyan Cobalt Blue": CIELabFromRGB(16, 35, 61, 100),
        "Cyan Cornflower Blue": CIELabFromRGB(9, 55, 76, 100),
        "Cyan (Process)": CIELabFromRGB(0, 72, 92, 100),
        "Cyber Grape": CIELabFromRGB(35, 26, 49, 100),
        "Cyber Yellow": CIELabFromRGB(100, 83, 0, 100),
        "Daffodil": CIELabFromRGB(100, 100, 19, 100),
        "Dandelion": CIELabFromRGB(94, 88, 19, 100),
        "Dark Blue": CIELabFromRGB(0, 0, 55, 100),
        "Dark Blue-Gray": CIELabFromRGB(40, 40, 60, 100),
        "Dark Brown": CIELabFromRGB(40, 26, 13, 100),
        "Dark Brown-Tangelo": CIELabFromRGB(53, 40, 31, 100),
        "Dark Byzantium": CIELabFromRGB(36, 22, 33, 100),
        "Dark Candy Apple Red": CIELabFromRGB(64, 0, 0, 100),
        "Dark Cerulean": CIELabFromRGB(3, 27, 49, 100),
        "Dark Chestnut": CIELabFromRGB(60, 41, 38, 100),
        "Dark Coral": CIELabFromRGB(80, 36, 27, 100),
        "Dark Cyan": CIELabFromRGB(0, 55, 55, 100),
        "Dark Electric Blue": CIELabFromRGB(33, 41, 47, 100),
        "Dark Goldenrod": CIELabFromRGB(72, 53, 4, 100),
        "Dark Gray (X11)": CIELabFromRGB(66, 66, 66, 100),
        "Dark Green": CIELabFromRGB(0, 20, 13, 100),
        "Dark Green (X11)": CIELabFromRGB(0, 39, 0, 100),
        "Dark Imperial Blue": CIELabFromRGB(0, 25, 42, 100),
        "Dark Imperial-er Blue": CIELabFromRGB(0, 8, 49, 100),
        "Dark Jungle Green": CIELabFromRGB(10, 14, 13, 100),
        "Dark Khaki": CIELabFromRGB(74, 72, 42, 100),
        "Dark Lava": CIELabFromRGB(28, 24, 20, 100),
        "Dark Lavender": CIELabFromRGB(45, 31, 59, 100),
        "Dark Liver": CIELabFromRGB(33, 29, 31, 100),
        "Dark Liver (Horses)": CIELabFromRGB(33, 24, 22, 100),
        "Dark Magenta": CIELabFromRGB(55, 0, 55, 100),
        "Dark Medium Gray": CIELabFromRGB(66, 66, 66, 100),
        "Dark Midnight Blue": CIELabFromRGB(0, 20, 40, 100),
        "Dark Moss Green": CIELabFromRGB(29, 36, 14, 100),
        "Dark Olive Green": CIELabFromRGB(33, 42, 18, 100),
        "Dark Orange": CIELabFromRGB(100, 55, 0, 100),
        "Dark Orchid": CIELabFromRGB(60, 20, 80, 100),
        "Dark Pastel Blue": CIELabFromRGB(47, 62, 80, 100),
        "Dark Pastel Green": CIELabFromRGB(1, 75, 24, 100),
        "Dark Pastel Purple": CIELabFromRGB(59, 44, 84, 100),
        "Dark Pastel Red": CIELabFromRGB(76, 23, 13, 100),
        "Dark Pink": CIELabFromRGB(91, 33, 50, 100),
        "Dark Powder Blue": CIELabFromRGB(0, 20, 60, 100),
        "Dark Puce": CIELabFromRGB(31, 23, 24, 100),
        "Dark Purple": CIELabFromRGB(19, 10, 20, 100),
        "Dark Raspberry": CIELabFromRGB(53, 15, 34, 100),
        "Dark Red": CIELabFromRGB(55, 0, 0, 100),
        "Dark Salmon": CIELabFromRGB(91, 59, 48, 100),
        "Dark Scarlet": CIELabFromRGB(34, 1, 10, 100),
        "Dark Sea Green": CIELabFromRGB(56, 74, 56, 100),
        "Dark Sienna": CIELabFromRGB(24, 8, 8, 100),
        "Dark Sky Blue": CIELabFromRGB(55, 75, 84, 100),
        "Dark Slate Blue": CIELabFromRGB(28, 24, 55, 100),
        "Dark Slate Gray": CIELabFromRGB(18, 31, 31, 100),
        "Dark Spring Green": CIELabFromRGB(9, 45, 27, 100),
        "Dark Tan": CIELabFromRGB(57, 51, 32, 100),
        "Dark Tangerine": CIELabFromRGB(100, 66, 7, 100),
        "Dark Taupe": CIELabFromRGB(28, 24, 20, 100),
        "Dark Terra Cotta": CIELabFromRGB(80, 31, 36, 100),
        "Dark Turquoise": CIELabFromRGB(0, 81, 82, 100),
        "Dark Vanilla": CIELabFromRGB(82, 75, 66, 100),
        "Dark Violet": CIELabFromRGB(58, 0, 83, 100),
        "Dark Yellow": CIELabFromRGB(61, 53, 5, 100),
        "Dartmouth Green": CIELabFromRGB(0, 44, 24, 100),
        "Davy's Grey": CIELabFromRGB(33, 33, 33, 100),
        "Debian Red": CIELabFromRGB(84, 4, 33, 100),
        "Deep Aquamarine": CIELabFromRGB(25, 51, 43, 100),
        "Deep Carmine": CIELabFromRGB(66, 13, 24, 100),
        "Deep Carmine Pink": CIELabFromRGB(94, 19, 22, 100),
        "Deep Carrot Orange": CIELabFromRGB(91, 41, 17, 100),
        "Deep Cerise": CIELabFromRGB(85, 20, 53, 100),
        "Deep Champagne": CIELabFromRGB(98, 84, 65, 100),
        "Deep Chestnut": CIELabFromRGB(73, 31, 28, 100),
        "Deep Coffee": CIELabFromRGB(44, 26, 25, 100),
        "Deep Fuchsia": CIELabFromRGB(76, 33, 76, 100),
        "Deep Green": CIELabFromRGB(2, 40, 3, 100),
        "Deep Green-Cyan Turquoise": CIELabFromRGB(5, 49, 38, 100),
        "Deep Jungle Green": CIELabFromRGB(0, 29, 29, 100),
        "Deep Koamaru": CIELabFromRGB(20, 20, 40, 100),
        "Deep Lemon": CIELabFromRGB(96, 78, 10, 100),
        "Deep Lilac": CIELabFromRGB(60, 33, 73, 100),
        "Deep Magenta": CIELabFromRGB(80, 0, 80, 100),
        "Deep Maroon": CIELabFromRGB(51, 0, 0, 100),
        "Deep Mauve": CIELabFromRGB(83, 45, 83, 100),
        "Deep Moss Green": CIELabFromRGB(21, 37, 23, 100),
        "Deep Peach": CIELabFromRGB(100, 80, 64, 100),
        "Deep Pink": CIELabFromRGB(100, 8, 58, 100),
        "Deep Puce": CIELabFromRGB(66, 36, 41, 100),
        "Deep Red": CIELabFromRGB(52, 0, 0, 100),
        "Deep Ruby": CIELabFromRGB(52, 25, 36, 100),
        "Deep Saffron": CIELabFromRGB(100, 60, 20, 100),
        "Deep Sky Blue": CIELabFromRGB(0, 75, 100, 100),
        "Deep Space Sparkle": CIELabFromRGB(29, 39, 42, 100),
        "Deep Spring Bud": CIELabFromRGB(33, 42, 18, 100),
        "Deep Taupe": CIELabFromRGB(49, 37, 38, 100),
        "Deep Tuscan Red": CIELabFromRGB(40, 26, 30, 100),
        "Deep Violet": CIELabFromRGB(20, 0, 40, 100),
        "Deer": CIELabFromRGB(73, 53, 35, 100),
        "Denim": CIELabFromRGB(8, 38, 74, 100),
        "Desaturated Cyan": CIELabFromRGB(40, 60, 60, 100),
        "Desert": CIELabFromRGB(76, 60, 42, 100),
        "Desert Sand": CIELabFromRGB(93, 79, 69, 100),
        "Desire": CIELabFromRGB(92, 24, 33, 100),
        "Diamond": CIELabFromRGB(73, 95, 100, 100),
        "Dim Gray": CIELabFromRGB(41, 41, 41, 100),
        "Dirt": CIELabFromRGB(61, 46, 33, 100),
        "Dodger Blue": CIELabFromRGB(12, 56, 100, 100),
        "Dogwood Rose": CIELabFromRGB(84, 9, 41, 100),
        "Dollar Bill": CIELabFromRGB(52, 73, 40, 100),
        "Donkey Brown": CIELabFromRGB(40, 30, 16, 100),
        "Drab": CIELabFromRGB(59, 44, 9, 100),
        "Duke Blue": CIELabFromRGB(0, 0, 61, 100),
        "Dust Storm": CIELabFromRGB(90, 80, 79, 100),
        "Dutch White": CIELabFromRGB(94, 87, 73, 100),
        "Earth Yellow": CIELabFromRGB(88, 66, 37, 100),
        "Ebony": CIELabFromRGB(33, 36, 31, 100),
        "Ecru": CIELabFromRGB(76, 70, 50, 100),
        "Eerie Black": CIELabFromRGB(11, 11, 11, 100),
        "Eggplant": CIELabFromRGB(38, 25, 32, 100),
        "Eggshell": CIELabFromRGB(94, 92, 84, 100),
        "Egyptian Blue": CIELabFromRGB(6, 20, 65, 100),
        "Electric Blue": CIELabFromRGB(49, 98, 100, 100),
        "Electric Crimson": CIELabFromRGB(100, 0, 25, 100),
        "Electric Cyan": CIELabFromRGB(0, 100, 100, 100),
        "Electric Green": CIELabFromRGB(0, 100, 0, 100),
        "Electric Indigo": CIELabFromRGB(44, 0, 100, 100),
        "Electric Lavender": CIELabFromRGB(96, 73, 100, 100),
        "Electric Lime": CIELabFromRGB(80, 100, 0, 100),
        "Electric Purple": CIELabFromRGB(75, 0, 100, 100),
        "Electric Ultramarine": CIELabFromRGB(25, 0, 100, 100),
        "Electric Violet": CIELabFromRGB(56, 0, 100, 100),
        "Electric Yellow": CIELabFromRGB(100, 100, 20, 100),
        "Emerald": CIELabFromRGB(31, 78, 47, 100),
        "Eminence": CIELabFromRGB(42, 19, 51, 100),
        "English Green": CIELabFromRGB(11, 30, 24, 100),
        "English Lavender": CIELabFromRGB(71, 51, 58, 100),
        "English Red": CIELabFromRGB(67, 29, 32, 100),
        "English Violet": CIELabFromRGB(34, 24, 36, 100),
        "Eton Blue": CIELabFromRGB(59, 78, 64, 100),
        "Eucalyptus": CIELabFromRGB(27, 84, 66, 100),
        "Fallow": CIELabFromRGB(76, 60, 42, 100),
        "Falu Red": CIELabFromRGB(50, 9, 9, 100),
        "Fandango": CIELabFromRGB(71, 20, 54, 100),
        "Fandango Pink": CIELabFromRGB(87, 32, 52, 100),
        "Fashion Fuchsia": CIELabFromRGB(96, 0, 63, 100),
        "Fawn": CIELabFromRGB(90, 67, 44, 100),
        "Feldgrau": CIELabFromRGB(30, 36, 33, 100),
        "Feldspar": CIELabFromRGB(99, 84, 69, 100),
        "Fern Green": CIELabFromRGB(31, 47, 26, 100),
        "Ferrari Red": CIELabFromRGB(100, 16, 0, 100),
        "Field Drab": CIELabFromRGB(42, 33, 12, 100),
        "Firebrick": CIELabFromRGB(70, 13, 13, 100),
        "Fire Engine Red": CIELabFromRGB(81, 13, 16, 100),
        "Flame": CIELabFromRGB(89, 35, 13, 100),
        "Flamingo Pink": CIELabFromRGB(99, 56, 67, 100),
        "Flattery": CIELabFromRGB(42, 27, 14, 100),
        "Flavescent": CIELabFromRGB(97, 91, 56, 100),
        "Flax": CIELabFromRGB(93, 86, 51, 100),
        "Flirt": CIELabFromRGB(64, 0, 43, 100),
        "Floral White": CIELabFromRGB(100, 98, 94, 100),
        "Fluorescent Orange": CIELabFromRGB(100, 75, 0, 100),
        "Fluorescent Pink": CIELabFromRGB(100, 8, 58, 100),
        "Fluorescent Yellow": CIELabFromRGB(80, 100, 0, 100),
        "Folly": CIELabFromRGB(100, 0, 31, 100),
        "Forest Green (Traditional)": CIELabFromRGB(0, 27, 13, 100),
        "Forest Green (Web)": CIELabFromRGB(13, 55, 13, 100),
        "French Beige": CIELabFromRGB(65, 48, 36, 100),
        "French Bistre": CIELabFromRGB(52, 43, 30, 100),
        "French Blue": CIELabFromRGB(0, 45, 73, 100),
        "French Fuchsia": CIELabFromRGB(99, 25, 57, 100),
        "French Lilac": CIELabFromRGB(53, 38, 56, 100),
        "French Lime": CIELabFromRGB(62, 99, 22, 100),
        "French Mauve": CIELabFromRGB(83, 45, 83, 100),
        "French Pink": CIELabFromRGB(99, 42, 62, 100),
        "French Plum": CIELabFromRGB(51, 8, 33, 100),
        "French Puce": CIELabFromRGB(31, 9, 4, 100),
        "French Raspberry": CIELabFromRGB(78, 17, 28, 100),
        "French Rose": CIELabFromRGB(96, 29, 54, 100),
        "French Sky Blue": CIELabFromRGB(47, 71, 100, 100),
        "French Violet": CIELabFromRGB(53, 2, 81, 100),
        "French Wine": CIELabFromRGB(67, 12, 27, 100),
        "Fresh Air": CIELabFromRGB(65, 91, 100, 100),
        "Fuchsia": CIELabFromRGB(100, 0, 100, 100),
        "Fuchsia (Crayola)": CIELabFromRGB(76, 33, 76, 100),
        "Fuchsia Pink": CIELabFromRGB(100, 47, 100, 100),
        "Fuchsia Purple": CIELabFromRGB(80, 22, 48, 100),
        "Fuchsia Rose": CIELabFromRGB(78, 26, 46, 100),
        "Fulvous": CIELabFromRGB(89, 52, 0, 100),
        "Fuzzy Wuzzy": CIELabFromRGB(80, 40, 40, 100),
        "Gainsboro": CIELabFromRGB(86, 86, 86, 100),
        "Gamboge": CIELabFromRGB(89, 61, 6, 100),
        "Gamboge Orange (Brown)": CIELabFromRGB(60, 40, 0, 100),
        "Generic Viridian": CIELabFromRGB(0, 50, 40, 100),
        "Ghost White": CIELabFromRGB(97, 97, 100, 100),
        "Giants Orange": CIELabFromRGB(100, 35, 11, 100),
        "Grussrel": CIELabFromRGB(69, 40, 0, 100),
        "Glaucous": CIELabFromRGB(38, 51, 71, 100),
        "Glitter": CIELabFromRGB(90, 91, 98, 100),
        "GO Green": CIELabFromRGB(0, 67, 40, 100),
        "Gold (Metallic)": CIELabFromRGB(83, 69, 22, 100),
        "Gold (Web) (Golden)": CIELabFromRGB(100, 84, 0, 100),
        "Gold Fusion": CIELabFromRGB(52, 46, 31, 100),
        "Golden Brown": CIELabFromRGB(60, 40, 8, 100),
        "Golden Poppy": CIELabFromRGB(99, 76, 0, 100),
        "Golden Yellow": CIELabFromRGB(100, 87, 0, 100),
        "Goldenrod": CIELabFromRGB(85, 65, 13, 100),
        "Granny Smith Apple": CIELabFromRGB(66, 89, 63, 100),
        "Grape": CIELabFromRGB(44, 18, 66, 100),
        "Gray": CIELabFromRGB(50, 50, 50, 100),
        "Gray (HTML/CSS Gray)": CIELabFromRGB(50, 50, 50, 100),
        "Gray (X11 Gray)": CIELabFromRGB(75, 75, 75, 100),
        "Gray-Asparagus": CIELabFromRGB(27, 35, 27, 100),
        "Gray-Blue": CIELabFromRGB(55, 57, 67, 100),
        "Green (Color Wheel) (X11 Green)": CIELabFromRGB(0, 100, 0, 100),
        "Green (Crayola)": CIELabFromRGB(11, 67, 47, 100),
        "Green (HTML/CSS Color)": CIELabFromRGB(0, 50, 0, 100),
        "Green (Munsell)": CIELabFromRGB(0, 66, 47, 100),
        "Green (NCS)": CIELabFromRGB(0, 62, 42, 100),
        "Green (Pantone)": CIELabFromRGB(0, 68, 26, 100),
        "Green (Pigment)": CIELabFromRGB(0, 65, 31, 100),
        "Green (RYB)": CIELabFromRGB(40, 69, 20, 100),
        "Green-Blue": CIELabFromRGB(7, 39, 71, 100),
        "Green-Cyan": CIELabFromRGB(0, 60, 40, 100),
        "Green-Yellow": CIELabFromRGB(68, 100, 18, 100),
        "Grizzly": CIELabFromRGB(53, 35, 9, 100),
        "Grullo": CIELabFromRGB(66, 60, 53, 100),
        "Guppie Green": CIELabFromRGB(0, 100, 50, 100),
        "Halayà Úbe": CIELabFromRGB(40, 22, 33, 100),
        "Han Blue": CIELabFromRGB(27, 42, 81, 100),
        "Han Purple": CIELabFromRGB(32, 9, 98, 100),
        "Hansa Yellow": CIELabFromRGB(91, 84, 42, 100),
        "Harlequin": CIELabFromRGB(25, 100, 0, 100),
        "Harlequin Green": CIELabFromRGB(27, 80, 9, 100),
        "Harvard Crimson": CIELabFromRGB(79, 0, 9, 100),
        "Harvest Gold": CIELabFromRGB(85, 57, 0, 100),
        "Heart Gold": CIELabFromRGB(50, 50, 0, 100),
        "Heliotrope": CIELabFromRGB(87, 45, 100, 100),
        "Heliotrope Gray": CIELabFromRGB(67, 60, 66, 100),
        "Heliotrope Magenta": CIELabFromRGB(67, 0, 73, 100),
        "Hollywood Cerise": CIELabFromRGB(96, 0, 63, 100),
        "Honeydew": CIELabFromRGB(94, 100, 94, 100),
        "Honolulu Blue": CIELabFromRGB(0, 43, 69, 100),
        "Hooker's Green": CIELabFromRGB(29, 47, 42, 100),
        "Hot Magenta": CIELabFromRGB(100, 11, 81, 100),
        "Hot Pink": CIELabFromRGB(100, 41, 71, 100),
        "Hunter Green": CIELabFromRGB(21, 37, 23, 100),
        "Iceberg": CIELabFromRGB(44, 65, 82, 100),
        "Icterine": CIELabFromRGB(99, 97, 37, 100),
        "Illuminating Emerald": CIELabFromRGB(19, 57, 47, 100),
        "Imperial": CIELabFromRGB(38, 18, 42, 100),
        "Imperial Blue": CIELabFromRGB(0, 14, 58, 100),
        "Imperial Purple": CIELabFromRGB(40, 1, 24, 100),
        "Imperial Red": CIELabFromRGB(93, 16, 22, 100),
        "Inchworm": CIELabFromRGB(70, 93, 36, 100),
        "Independence": CIELabFromRGB(30, 32, 43, 100),
        "India Green": CIELabFromRGB(7, 53, 3, 100),
        "Indian Red": CIELabFromRGB(80, 36, 36, 100),
        "Indian Yellow": CIELabFromRGB(89, 66, 34, 100),
        "Indigo": CIELabFromRGB(44, 0, 100, 100),
        "Indigo Dye": CIELabFromRGB(4, 12, 57, 100),
        "Indigo (Web)": CIELabFromRGB(29, 0, 51, 100),
        "International Klein Blue": CIELabFromRGB(0, 18, 65, 100),
        "International Orange (Aerospace)": CIELabFromRGB(100, 31, 0, 100),
        "International Orange (Engineering)": CIELabFromRGB(73, 9, 5, 100),
        "International Orange (Golden Gate Bridge)": CIELabFromRGB(75, 21, 17, 100),
        "Iris": CIELabFromRGB(35, 31, 81, 100),
        "Irresistible": CIELabFromRGB(70, 27, 42, 100),
        "Isabelline": CIELabFromRGB(96, 94, 93, 100),
        "Islamic Green": CIELabFromRGB(0, 56, 0, 100),
        "Italian Sky Blue": CIELabFromRGB(70, 100, 100, 100),
        "Ivory": CIELabFromRGB(100, 100, 94, 100),
        "Jade": CIELabFromRGB(0, 66, 42, 100),
        "Japanese Carmine": CIELabFromRGB(62, 16, 20, 100),
        "Japanese Indigo": CIELabFromRGB(15, 26, 28, 100),
        "Japanese Violet": CIELabFromRGB(36, 20, 34, 100),
        "Jasmine": CIELabFromRGB(97, 87, 49, 100),
        "Jasper": CIELabFromRGB(84, 23, 24, 100),
        "Jazzberry Jam": CIELabFromRGB(65, 4, 37, 100),
        "Jelly Bean": CIELabFromRGB(85, 38, 31, 100),
        "Jet": CIELabFromRGB(20, 20, 20, 100),
        "Jonquil": CIELabFromRGB(96, 79, 9, 100),
        "Jordy Blue": CIELabFromRGB(54, 73, 95, 100),
        "June Bud": CIELabFromRGB(74, 85, 34, 100),
        "Jungle Green": CIELabFromRGB(16, 67, 53, 100),
        "Kelly Green": CIELabFromRGB(30, 73, 9, 100),
        "Kenyan Copper": CIELabFromRGB(49, 11, 2, 100),
        "Keppel": CIELabFromRGB(23, 69, 62, 100),
        "Jawad/Chicken Color (HTML/CSS) (Khaki)": CIELabFromRGB(76, 69, 57, 100),
        "Khaki (X11) (Light Khaki)": CIELabFromRGB(94, 90, 55, 100),
        "Kobe": CIELabFromRGB(53, 18, 9, 100),
        "Kobi": CIELabFromRGB(91, 62, 77, 100),
        "Kombu Green": CIELabFromRGB(21, 26, 19, 100),
        "KU Crimson": CIELabFromRGB(91, 0, 5, 100),
        "La Salle Green": CIELabFromRGB(3, 47, 19, 100),
        "Languid Lavender": CIELabFromRGB(84, 79, 87, 100),
        "Lapis Lazuli": CIELabFromRGB(15, 38, 61, 100),
        "Laser Lemon": CIELabFromRGB(100, 100, 40, 100),
        "Laurel Green": CIELabFromRGB(66, 73, 62, 100),
        "Lava": CIELabFromRGB(81, 6, 13, 100),
        "Lavender (Floral)": CIELabFromRGB(71, 49, 86, 100),
        "Lavender (Web)": CIELabFromRGB(90, 90, 98, 100),
        "Lavender Blue": CIELabFromRGB(80, 80, 100, 100),
        "Lavender Blush": CIELabFromRGB(100, 94, 96, 100),
        "Lavender Gray": CIELabFromRGB(77, 76, 82, 100),
        "Lavender Indigo": CIELabFromRGB(58, 34, 92, 100),
        "Lavender Magenta": CIELabFromRGB(93, 51, 93, 100),
        "Lavender Mist": CIELabFromRGB(90, 90, 98, 100),
        "Lavender Pink": CIELabFromRGB(98, 68, 82, 100),
        "Lavender Purple": CIELabFromRGB(59, 48, 71, 100),
        "Lavender Rose": CIELabFromRGB(98, 63, 89, 100),
        "Lawn Green": CIELabFromRGB(49, 99, 0, 100),
        "Lemon": CIELabFromRGB(100, 97, 0, 100),
        "Lemon Chiffon": CIELabFromRGB(100, 98, 80, 100),
        "Lemon Curry": CIELabFromRGB(80, 63, 11, 100),
        "Lemon Glacier": CIELabFromRGB(99, 100, 0, 100),
        "Lemon Lime": CIELabFromRGB(89, 100, 0, 100),
        "Lemon Meringue": CIELabFromRGB(96, 92, 75, 100),
        "Lemon Yellow": CIELabFromRGB(100, 96, 31, 100),
        "Lenurple": CIELabFromRGB(73, 58, 85, 100),
        "Licorice": CIELabFromRGB(10, 7, 6, 100),
        "Liberty": CIELabFromRGB(33, 35, 65, 100),
        "Light Apricot": CIELabFromRGB(99, 84, 69, 100),
        "Light Blue": CIELabFromRGB(68, 85, 90, 100),
        "Light Brilliant Red": CIELabFromRGB(100, 18, 18, 100),
        "Light Brown": CIELabFromRGB(71, 40, 11, 100),
        "Light Carmine Pink": CIELabFromRGB(90, 40, 44, 100),
        "Light Cobalt Blue": CIELabFromRGB(53, 67, 88, 100),
        "Light Coral": CIELabFromRGB(94, 50, 50, 100),
        "Light Cornflower Blue": CIELabFromRGB(58, 80, 92, 100),
        "Light Crimson": CIELabFromRGB(96, 41, 57, 100),
        "Light Cyan": CIELabFromRGB(88, 100, 100, 100),
        "Light Deep Pink": CIELabFromRGB(100, 36, 80, 100),
        "Light French Beige": CIELabFromRGB(78, 68, 50, 100),
        "Light Fuchsia Pink": CIELabFromRGB(98, 52, 94, 100),
        "Light Goldenrod Yellow": CIELabFromRGB(98, 98, 82, 100),
        "Light Gray": CIELabFromRGB(83, 83, 83, 100),
        "Light Grayish Magenta": CIELabFromRGB(80, 60, 80, 100),
        "Light Green": CIELabFromRGB(56, 93, 56, 100),
        "Light Hot Pink": CIELabFromRGB(100, 70, 87, 100),
        "Light Khaki": CIELabFromRGB(94, 90, 55, 100),
        "Light Medium Orchid": CIELabFromRGB(83, 61, 80, 100),
        "Light Moss Green": CIELabFromRGB(68, 87, 68, 100),
        "Light Orchid": CIELabFromRGB(90, 66, 84, 100),
        "Light Pastel Purple": CIELabFromRGB(69, 61, 85, 100),
        "Light Pink": CIELabFromRGB(100, 71, 76, 100),
        "Light Red Ochre": CIELabFromRGB(91, 45, 32, 100),
        "Light Salmon": CIELabFromRGB(100, 63, 48, 100),
        "Light Salmon Pink": CIELabFromRGB(100, 60, 60, 100),
        "Light Sea Green": CIELabFromRGB(13, 70, 67, 100),
        "Light Sky Blue": CIELabFromRGB(53, 81, 98, 100),
        "Light Slate Gray": CIELabFromRGB(47, 53, 60, 100),
        "Light Steel Blue": CIELabFromRGB(69, 77, 87, 100),
        "Light Taupe": CIELabFromRGB(70, 55, 43, 100),
        "Light Thulian Pink": CIELabFromRGB(90, 56, 67, 100),
        "Light Yellow": CIELabFromRGB(100, 100, 88, 100),
        "Lilac": CIELabFromRGB(78, 64, 78, 100),
        "Lime (Color Wheel)": CIELabFromRGB(75, 100, 0, 100),
        "Lime (Web) (X11 Green)": CIELabFromRGB(0, 100, 0, 100),
        "Lime Green": CIELabFromRGB(20, 80, 20, 100),
        "Limerick": CIELabFromRGB(62, 76, 4, 100),
        "Lincoln Green": CIELabFromRGB(10, 35, 2, 100),
        "Linen": CIELabFromRGB(98, 94, 90, 100),
        "Lion": CIELabFromRGB(76, 60, 42, 100),
        "Liseran Purple": CIELabFromRGB(87, 44, 63, 100),
        "Little Boy Blue": CIELabFromRGB(42, 63, 86, 100),
        "Liver": CIELabFromRGB(40, 30, 28, 100),
        "Liver (Dogs)": CIELabFromRGB(72, 43, 16, 100),
        "Liver (Organ)": CIELabFromRGB(42, 18, 12, 100),
        "Liver Chestnut": CIELabFromRGB(60, 45, 34, 100),
        "Livid": CIELabFromRGB(40, 60, 80, 100),
        "Lumber": CIELabFromRGB(100, 89, 80, 100),
        "Lust": CIELabFromRGB(90, 13, 13, 100),
        "Magenta": CIELabFromRGB(100, 0, 100, 100),
        "Magenta (Crayola)": CIELabFromRGB(100, 33, 64, 100),
        "Magenta (Dye)": CIELabFromRGB(79, 12, 48, 100),
        "Magenta (Pantone)": CIELabFromRGB(82, 25, 49, 100),
        "Magenta (Process)": CIELabFromRGB(100, 0, 56, 100),
        "Magenta Haze": CIELabFromRGB(62, 27, 46, 100),
        "Magenta-Pink": CIELabFromRGB(80, 20, 55, 100),
        "Magic Mint": CIELabFromRGB(67, 94, 82, 100),
        "Magnolia": CIELabFromRGB(97, 96, 100, 100),
        "Mahogany": CIELabFromRGB(75, 25, 0, 100),
        "Maize": CIELabFromRGB(98, 93, 36, 100),
        "Majorelle Blue": CIELabFromRGB(38, 31, 86, 100),
        "Malachite": CIELabFromRGB(4, 85, 32, 100),
        "Manatee": CIELabFromRGB(59, 60, 67, 100),
        "Mango Tango": CIELabFromRGB(100, 51, 26, 100),
        "Mantis": CIELabFromRGB(45, 76, 40, 100),
        "Mardi Gras": CIELabFromRGB(53, 0, 52, 100),
        "Marigold": CIELabFromRGB(92, 64, 13, 100),
        "Maroon (Crayola)": CIELabFromRGB(76, 13, 28, 100),
        "Maroon (HTML/CSS)": CIELabFromRGB(50, 0, 0, 100),
        "Maroon (X11)": CIELabFromRGB(69, 19, 38, 100),
        "Mauve": CIELabFromRGB(88, 69, 100, 100),
        "Mauve Taupe": CIELabFromRGB(57, 37, 43, 100),
        "Mauvelous": CIELabFromRGB(94, 60, 67, 100),
        "May Green": CIELabFromRGB(30, 57, 25, 100),
        "Maya Blue": CIELabFromRGB(45, 76, 98, 100),
        "Meat Brown": CIELabFromRGB(90, 72, 23, 100),
        "Medium Aquamarine": CIELabFromRGB(40, 87, 67, 100),
        "Medium Blue": CIELabFromRGB(0, 0, 80, 100),
        "Medium Candy Apple Red": CIELabFromRGB(89, 2, 17, 100),
        "Medium Carmine": CIELabFromRGB(69, 25, 21, 100),
        "Medium Champagne": CIELabFromRGB(95, 90, 67, 100),
        "Medium Electric Blue": CIELabFromRGB(1, 31, 59, 100),
        "Medium Jungle Green": CIELabFromRGB(11, 21, 18, 100),
        "Medium Lavender Magenta": CIELabFromRGB(87, 63, 87, 100),
        "Medium Orchid": CIELabFromRGB(73, 33, 83, 100),
        "Medium Persian Blue": CIELabFromRGB(0, 40, 65, 100),
        "Medium Purple": CIELabFromRGB(58, 44, 86, 100),
        "Medium Red-Violet": CIELabFromRGB(73, 20, 52, 100),
        "Medium Ruby": CIELabFromRGB(67, 25, 41, 100),
        "Medium Sea Green": CIELabFromRGB(24, 70, 44, 100),
        "Medium Sky Blue": CIELabFromRGB(50, 85, 92, 100),
        "Medium Slate Blue": CIELabFromRGB(48, 41, 93, 100),
        "Medium Spring Bud": CIELabFromRGB(79, 86, 53, 100),
        "Medium Spring Green": CIELabFromRGB(0, 98, 60, 100),
        "Medium Taupe": CIELabFromRGB(40, 30, 28, 100),
        "Medium Turquoise": CIELabFromRGB(28, 82, 80, 100),
        "Medium Tuscan Red": CIELabFromRGB(47, 27, 23, 100),
        "Medium Vermilion": CIELabFromRGB(85, 38, 23, 100),
        "Medium Violet-Red": CIELabFromRGB(78, 8, 52, 100),
        "Mellow Apricot": CIELabFromRGB(97, 72, 47, 100),
        "Mellow Yellow": CIELabFromRGB(97, 87, 49, 100),
        "Melon": CIELabFromRGB(99, 74, 71, 100),
        "Metallic Seaweed": CIELabFromRGB(4, 49, 55, 100),
        "Metallic Sunburst": CIELabFromRGB(61, 49, 22, 100),
        "Mexican Pink": CIELabFromRGB(89, 0, 49, 100),
        "Midnight Blue": CIELabFromRGB(10, 10, 44, 100),
        "Midnight Green (Eagle Green)": CIELabFromRGB(0, 29, 33, 100),
        "Mikado Yellow": CIELabFromRGB(100, 77, 5, 100),
        "Mindaro": CIELabFromRGB(89, 98, 53, 100),
        "Ming": CIELabFromRGB(21, 45, 49, 100),
        "Mint": CIELabFromRGB(24, 71, 54, 100),
        "Mint Cream": CIELabFromRGB(96, 100, 98, 100),
        "Mint Green": CIELabFromRGB(60, 100, 60, 100),
        "Misty Rose": CIELabFromRGB(100, 89, 88, 100),
        "Moccasin": CIELabFromRGB(98, 92, 84, 100),
        "Mode Beige": CIELabFromRGB(59, 44, 9, 100),
        "Moonstone Blue": CIELabFromRGB(45, 66, 76, 100),
        "Mordant Red 19": CIELabFromRGB(68, 5, 0, 100),
        "Moss Green": CIELabFromRGB(54, 60, 36, 100),
        "Mountain Meadow": CIELabFromRGB(19, 73, 56, 100),
        "Mountbatten Pink": CIELabFromRGB(60, 48, 55, 100),
        "MSU Green": CIELabFromRGB(9, 27, 23, 100),
        "Mughal Green": CIELabFromRGB(19, 38, 19, 100),
        "Mulberry": CIELabFromRGB(77, 29, 55, 100),
        "Mustard": CIELabFromRGB(100, 86, 35, 100),
        "Myrtle Green": CIELabFromRGB(19, 47, 45, 100),
        "Nadeshiko Pink": CIELabFromRGB(96, 68, 78, 100),
        "Napier Green": CIELabFromRGB(16, 50, 0, 100),
        "Naples Yellow": CIELabFromRGB(98, 85, 37, 100),
        "Navajo White": CIELabFromRGB(100, 87, 68, 100),
        "Navy": CIELabFromRGB(0, 0, 50, 100),
        "Navy Purple": CIELabFromRGB(58, 34, 92, 100),
        "Neon Carrot": CIELabFromRGB(100, 64, 26, 100),
        "Neon Fuchsia": CIELabFromRGB(100, 25, 39, 100),
        "Neon Green": CIELabFromRGB(22, 100, 8, 100),
        "New Car": CIELabFromRGB(13, 31, 78, 100),
        "New York Pink": CIELabFromRGB(84, 51, 50, 100),
        "Non-Photo Blue": CIELabFromRGB(64, 87, 93, 100),
        "North Texas Green": CIELabFromRGB(2, 56, 20, 100),
        "Nyanza": CIELabFromRGB(91, 100, 86, 100),
        "Ocean Boat Blue": CIELabFromRGB(0, 47, 75, 100),
        "Ochre": CIELabFromRGB(80, 47, 13, 100),
        "Office Green": CIELabFromRGB(0, 50, 0, 100),
        "Old Burgundy": CIELabFromRGB(26, 19, 18, 100),
        "Old Gold": CIELabFromRGB(81, 71, 23, 100),
        "Old Heliotrope": CIELabFromRGB(34, 24, 36, 100),
        "Old Lace": CIELabFromRGB(99, 96, 90, 100),
        "Old Lavender": CIELabFromRGB(47, 41, 47, 100),
        "Old Mauve": CIELabFromRGB(40, 19, 28, 100),
        "Old Moss Green": CIELabFromRGB(53, 49, 21, 100),
        "Old Rose": CIELabFromRGB(75, 50, 51, 100),
        "Old Silver": CIELabFromRGB(52, 52, 51, 100),
        "Olive": CIELabFromRGB(50, 50, 0, 100),
        "Olive Drab": CIELabFromRGB(24, 20, 12, 100),
        "Olivine": CIELabFromRGB(60, 73, 45, 100),
        "Onyx": CIELabFromRGB(21, 22, 22, 100),
        "Opera Mauve": CIELabFromRGB(72, 52, 65, 100),
        "Orange (Color Wheel)": CIELabFromRGB(100, 50, 0, 100),
        "Orange (Crayola)": CIELabFromRGB(100, 46, 22, 100),
        "Orange (Pantone)": CIELabFromRGB(100, 35, 0, 100),
        "Orange (RYB)": CIELabFromRGB(98, 60, 1, 100),
        "Orange (Web)": CIELabFromRGB(100, 65, 0, 100),
        "Orange Peel": CIELabFromRGB(100, 62, 0, 100),
        "Orange-Red": CIELabFromRGB(100, 27, 0, 100),
        "Orange-Yellow": CIELabFromRGB(97, 84, 41, 100),
        "Orchid": CIELabFromRGB(85, 44, 84, 100),
        "Orchid Pink": CIELabFromRGB(95, 74, 80, 100),
        "Orioles Orange": CIELabFromRGB(98, 31, 8, 100),
        "Otter Brown": CIELabFromRGB(40, 26, 13, 100),
        "Outer Space": CIELabFromRGB(25, 29, 30, 100),
        "Outrageous Orange": CIELabFromRGB(100, 43, 29, 100),
        "Oxford Blue": CIELabFromRGB(0, 13, 28, 100),
        "OU Crimson Red": CIELabFromRGB(60, 0, 0, 100),
        "Pakistan Green": CIELabFromRGB(0, 40, 0, 100),
        "Palatinate Blue": CIELabFromRGB(15, 23, 89, 100),
        "Palatinate Purple": CIELabFromRGB(41, 16, 38, 100),
        "Pale Aqua": CIELabFromRGB(74, 83, 90, 100),
        "Pale Blue": CIELabFromRGB(69, 93, 93, 100),
        "Pale Brown": CIELabFromRGB(60, 46, 33, 100),
        "Pale Carmine": CIELabFromRGB(69, 25, 21, 100),
        "Pale Cerulean": CIELabFromRGB(61, 77, 89, 100),
        "Pale Chestnut": CIELabFromRGB(87, 68, 69, 100),
        "Pale Copper": CIELabFromRGB(85, 54, 40, 100),
        "Pale Cornflower Blue": CIELabFromRGB(67, 80, 94, 100),
        "Pale Cyan": CIELabFromRGB(53, 83, 97, 100),
        "Pale Gold": CIELabFromRGB(90, 75, 54, 100),
        "Pale Goldenrod": CIELabFromRGB(93, 91, 67, 100),
        "Pale Green": CIELabFromRGB(60, 98, 60, 100),
        "Pale Lavender": CIELabFromRGB(86, 82, 100, 100),
        "Pale Magenta": CIELabFromRGB(98, 52, 90, 100),
        "Pale Magenta-Pink": CIELabFromRGB(100, 60, 80, 100),
        "Pale Pink": CIELabFromRGB(98, 85, 87, 100),
        "Pale Plum": CIELabFromRGB(87, 63, 87, 100),
        "Pale Red-Violet": CIELabFromRGB(86, 44, 58, 100),
        "Pale Robin Egg Blue": CIELabFromRGB(59, 87, 82, 100),
        "Pale Silver": CIELabFromRGB(79, 75, 73, 100),
        "Pale Spring Bud": CIELabFromRGB(93, 92, 74, 100),
        "Pale Taupe": CIELabFromRGB(74, 60, 49, 100),
        "Pale Turquoise": CIELabFromRGB(69, 93, 93, 100),
        "Pale Violet": CIELabFromRGB(80, 60, 100, 100),
        "Pale Violet-Red": CIELabFromRGB(86, 44, 58, 100),
        "Pansy Purple": CIELabFromRGB(47, 9, 29, 100),
        "Paolo Veronese Green": CIELabFromRGB(0, 61, 49, 100),
        "Papaya Whip": CIELabFromRGB(100, 94, 84, 100),
        "Paradise Pink": CIELabFromRGB(90, 24, 38, 100),
        "Paris Green": CIELabFromRGB(31, 78, 47, 100),
        "Pastel Blue": CIELabFromRGB(68, 78, 81, 100),
        "Pastel Brown": CIELabFromRGB(51, 41, 33, 100),
        "Pastel Gray": CIELabFromRGB(81, 81, 77, 100),
        "Pastel Green": CIELabFromRGB(47, 87, 47, 100),
        "Pastel Magenta": CIELabFromRGB(96, 60, 76, 100),
        "Pastel Orange": CIELabFromRGB(100, 70, 28, 100),
        "Pastel Pink": CIELabFromRGB(87, 65, 64, 100),
        "Pastel Purple": CIELabFromRGB(70, 62, 71, 100),
        "Pastel Red": CIELabFromRGB(100, 41, 38, 100),
        "Pastel Violet": CIELabFromRGB(80, 60, 79, 100),
        "Pastel Yellow": CIELabFromRGB(99, 99, 59, 100),
        "Patriarch": CIELabFromRGB(50, 0, 50, 100),
        "Payne's Grey": CIELabFromRGB(33, 41, 47, 100),
        "Peachier": CIELabFromRGB(100, 90, 71, 100),
        "Peach": CIELabFromRGB(100, 80, 64, 100),
        "Peach-Orange": CIELabFromRGB(100, 80, 60, 100),
        "Peach Puff": CIELabFromRGB(100, 85, 73, 100),
        "Peach-Yellow": CIELabFromRGB(98, 87, 68, 100),
        "Pear": CIELabFromRGB(82, 89, 19, 100),
        "Pearl": CIELabFromRGB(92, 88, 78, 100),
        "Pearl Aqua": CIELabFromRGB(53, 85, 75, 100),
        "Pearly Purple": CIELabFromRGB(72, 41, 64, 100),
        "Peridot": CIELabFromRGB(90, 89, 0, 100),
        "Periwinkle": CIELabFromRGB(80, 80, 100, 100),
        "Persian Blue": CIELabFromRGB(11, 22, 73, 100),
        "Persian Green": CIELabFromRGB(0, 65, 58, 100),
        "Persian Indigo": CIELabFromRGB(20, 7, 48, 100),
        "Persian Orange": CIELabFromRGB(85, 56, 35, 100),
        "Persian Pink": CIELabFromRGB(97, 50, 75, 100),
        "Persian Plum": CIELabFromRGB(44, 11, 11, 100),
        "Persian Red": CIELabFromRGB(80, 20, 20, 100),
        "Persian Rose": CIELabFromRGB(100, 16, 64, 100),
        "Persimmon": CIELabFromRGB(93, 35, 0, 100),
        "Peru": CIELabFromRGB(80, 52, 25, 100),
        "Phlox": CIELabFromRGB(87, 0, 100, 100),
        "Phthalo Blue": CIELabFromRGB(0, 6, 54, 100),
        "Phthalo Green": CIELabFromRGB(7, 21, 14, 100),
        "Picton Blue": CIELabFromRGB(27, 69, 91, 100),
        "Pictorial Carmine": CIELabFromRGB(76, 4, 31, 100),
        "Piggy Pink": CIELabFromRGB(99, 87, 90, 100),
        "Pine Green": CIELabFromRGB(0, 47, 44, 100),
        "Pineapple": CIELabFromRGB(34, 24, 5, 100),
        "Pink": CIELabFromRGB(100, 75, 80, 100),
        "Pink (Pantone)": CIELabFromRGB(84, 28, 58, 100),
        "Pink Lace": CIELabFromRGB(100, 87, 96, 100),
        "Pink Lavender": CIELabFromRGB(85, 70, 82, 100),
        "Pink-Orange": CIELabFromRGB(100, 60, 40, 100),
        "Pink Pearl": CIELabFromRGB(91, 67, 81, 100),
        "Pink Raspberry": CIELabFromRGB(60, 0, 21, 100),
        "Pink Sherbet": CIELabFromRGB(97, 56, 65, 100),
        "Pistachio": CIELabFromRGB(58, 77, 45, 100),
        "Platinum": CIELabFromRGB(90, 89, 89, 100),
        "Plum": CIELabFromRGB(56, 27, 52, 100),
        "Plum (Web)": CIELabFromRGB(87, 63, 87, 100),
        "Pomp And Power": CIELabFromRGB(53, 38, 56, 100),
        "Popstar": CIELabFromRGB(75, 31, 38, 100),
        "Portland Orange": CIELabFromRGB(100, 35, 21, 100),
        "Powder Blue": CIELabFromRGB(69, 88, 90, 100),
        "Princeton Orange": CIELabFromRGB(96, 50, 15, 100),
        "Prune": CIELabFromRGB(44, 11, 11, 100),
        "Prussian Blue": CIELabFromRGB(0, 19, 33, 100),
        "Psychedelic Purple": CIELabFromRGB(87, 0, 100, 100),
        "Puce": CIELabFromRGB(80, 53, 60, 100),
        "Puce Red": CIELabFromRGB(45, 18, 22, 100),
        "Pullman Brown (UPS Brown)": CIELabFromRGB(39, 25, 9, 100),
        "Pullman Green": CIELabFromRGB(23, 20, 11, 100),
        "Pumpkin": CIELabFromRGB(100, 46, 9, 100),
        "Purple (HTML)": CIELabFromRGB(50, 0, 50, 100),
        "Purple (Munsell)": CIELabFromRGB(62, 0, 77, 100),
        "Purple (X11)": CIELabFromRGB(63, 13, 94, 100),
        "Purple Heart": CIELabFromRGB(41, 21, 61, 100),
        "Purple Mountain Majesty": CIELabFromRGB(59, 47, 71, 100),
        "Purple Navy": CIELabFromRGB(31, 32, 50, 100),
        "Purple Pizzazz": CIELabFromRGB(100, 31, 85, 100),
        "Purple Taupe": CIELabFromRGB(31, 25, 30, 100),
        "Purpureus": CIELabFromRGB(60, 31, 68, 100),
        "Quartz": CIELabFromRGB(32, 28, 31, 100),
        "Queen Blue": CIELabFromRGB(26, 42, 58, 100),
        "Queen Pink": CIELabFromRGB(91, 80, 84, 100),
        "Quinacridone Magenta": CIELabFromRGB(56, 23, 35, 100),
        "Rackley": CIELabFromRGB(36, 54, 66, 100),
        "Radical Red": CIELabFromRGB(100, 21, 37, 100),
        "Rajah": CIELabFromRGB(98, 67, 38, 100),
        "Raspberry": CIELabFromRGB(89, 4, 36, 100),
        "Raspberry Glace": CIELabFromRGB(57, 37, 43, 100),
        "Raspberry Pink": CIELabFromRGB(89, 31, 60, 100),
        "Raspberry Rose": CIELabFromRGB(70, 27, 42, 100),
        "Raw Umber": CIELabFromRGB(51, 40, 27, 100),
        "Razzle Dazzle Rose": CIELabFromRGB(100, 20, 80, 100),
        "Razzmatazz": CIELabFromRGB(89, 15, 42, 100),
        "Razzmic Berry": CIELabFromRGB(55, 31, 52, 100),
        "Rebecca Purple": CIELabFromRGB(40, 20, 60, 100),
        "Red": CIELabFromRGB(100, 0, 0, 100),
        "Red (Crayola)": CIELabFromRGB(93, 13, 30, 100),
        "Red (Munsell)": CIELabFromRGB(95, 0, 24, 100),
        "Red (NCS)": CIELabFromRGB(77, 1, 20, 100),
        "Red (Pantone)": CIELabFromRGB(93, 16, 22, 100),
        "Red (Pigment)": CIELabFromRGB(93, 11, 14, 100),
        "Red (RYB)": CIELabFromRGB(100, 15, 7, 100),
        "Red-Brown": CIELabFromRGB(65, 16, 16, 100),
        "Red Devil": CIELabFromRGB(53, 0, 7, 100),
        "Red-Orange": CIELabFromRGB(100, 33, 29, 100),
        "Red-Purple": CIELabFromRGB(89, 0, 47, 100),
        "Red-Violet": CIELabFromRGB(78, 8, 52, 100),
        "Redwood": CIELabFromRGB(64, 35, 32, 100),
        "Regalia": CIELabFromRGB(32, 18, 50, 100),
        "Registration Black": CIELabFromRGB(0, 0, 0, 100),
        "Resolution Blue": CIELabFromRGB(0, 14, 53, 100),
        "Rhythm": CIELabFromRGB(47, 46, 59, 100),
        "Rich Black": CIELabFromRGB(0, 25, 25, 100),
        "Rich Black (FOGRA29)": CIELabFromRGB(0, 4, 7, 100),
        "Rich Black (FOGRA39)": CIELabFromRGB(0, 1, 1, 100),
        "Rich Brilliant Lavender": CIELabFromRGB(95, 65, 100, 100),
        "Rich Carmine": CIELabFromRGB(84, 0, 25, 100),
        "Rich Electric Blue": CIELabFromRGB(3, 57, 82, 100),
        "Rich Lavender": CIELabFromRGB(65, 42, 81, 100),
        "Rich Lilac": CIELabFromRGB(71, 40, 82, 100),
        "Rich Maroon": CIELabFromRGB(69, 19, 38, 100),
        "Rifle Green": CIELabFromRGB(27, 30, 22, 100),
        "Roast Coffee": CIELabFromRGB(44, 26, 25, 100),
        "Robin Egg Blue": CIELabFromRGB(0, 80, 80, 100),
        "Rocket Metallic": CIELabFromRGB(54, 50, 50, 100),
        "Roman Silver": CIELabFromRGB(51, 54, 59, 100),
        "Rose": CIELabFromRGB(100, 0, 50, 100),
        "Rose Bonbon": CIELabFromRGB(98, 26, 62, 100),
        "Rose Ebony": CIELabFromRGB(40, 28, 27, 100),
        "Rose Gold": CIELabFromRGB(72, 43, 47, 100),
        "Rose Madder": CIELabFromRGB(89, 15, 21, 100),
        "Rose Pink": CIELabFromRGB(100, 40, 80, 100),
        "Rose Quartz": CIELabFromRGB(67, 60, 66, 100),
        "Rose Red": CIELabFromRGB(76, 12, 34, 100),
        "Rose Taupe": CIELabFromRGB(56, 36, 36, 100),
        "Rose Vale": CIELabFromRGB(67, 31, 32, 100),
        "Rosewood": CIELabFromRGB(40, 0, 4, 100),
        "Rosso Corsa": CIELabFromRGB(83, 0, 0, 100),
        "Rosy Brown": CIELabFromRGB(74, 56, 56, 100),
        "Royal Azure": CIELabFromRGB(0, 22, 66, 100),
        "Royal Blue": CIELabFromRGB(0, 14, 40, 100),
        "Royal Blue 2": CIELabFromRGB(25, 41, 88, 100),
        "Royal Fuchsia": CIELabFromRGB(79, 17, 57, 100),
        "Royal Purple": CIELabFromRGB(47, 32, 66, 100),
        "Royal Yellow": CIELabFromRGB(98, 85, 37, 100),
        "Ruber": CIELabFromRGB(81, 27, 46, 100),
        "Rubine Red": CIELabFromRGB(82, 0, 34, 100),
        "Ruby": CIELabFromRGB(88, 7, 37, 100),
        "Ruby Red": CIELabFromRGB(61, 7, 12, 100),
        "Ruddy": CIELabFromRGB(100, 0, 16, 100),
        "Ruddy Brown": CIELabFromRGB(73, 40, 16, 100),
        "Ruddy Pink": CIELabFromRGB(88, 56, 59, 100),
        "Rufous": CIELabFromRGB(66, 11, 3, 100),
        "Russet": CIELabFromRGB(50, 27, 11, 100),
        "Russian Green": CIELabFromRGB(40, 57, 40, 100),
        "Russian Violet": CIELabFromRGB(20, 9, 30, 100),
        "Rust": CIELabFromRGB(72, 25, 5, 100),
        "Rusty Red": CIELabFromRGB(85, 17, 26, 100),
        "Sacramento State Green": CIELabFromRGB(0, 34, 25, 100),
        "Saddle Brown": CIELabFromRGB(55, 27, 7, 100),
        "Safety Orange": CIELabFromRGB(100, 47, 0, 100),
        "Safety Orange (Blaze Orange)": CIELabFromRGB(100, 40, 0, 100),
        "Safety Yellow": CIELabFromRGB(93, 82, 1, 100),
        "Saffron": CIELabFromRGB(96, 77, 19, 100),
        "Sage": CIELabFromRGB(74, 72, 54, 100),
        "St. Patrick's Blue": CIELabFromRGB(14, 16, 48, 100),
        "Salmon": CIELabFromRGB(98, 50, 45, 100),
        "Salmon Pink": CIELabFromRGB(100, 57, 64, 100),
        "Sand": CIELabFromRGB(76, 70, 50, 100),
        "Sand Dune": CIELabFromRGB(59, 44, 9, 100),
        "Sandstorm": CIELabFromRGB(93, 84, 25, 100),
        "Sandy Brown": CIELabFromRGB(96, 64, 38, 100),
        "Sandy Taupe": CIELabFromRGB(59, 44, 9, 100),
        "Sangria": CIELabFromRGB(57, 0, 4, 100),
        "Sap Green": CIELabFromRGB(31, 49, 16, 100),
        "Sapphire": CIELabFromRGB(6, 32, 73, 100),
        "Sapphire Blue": CIELabFromRGB(0, 40, 65, 100),
        "Satin Sheen Gold": CIELabFromRGB(80, 63, 21, 100),
        "Scarlet": CIELabFromRGB(100, 14, 0, 100),
        "Scarlet-ier": CIELabFromRGB(99, 5, 21, 100),
        "Schauss Pink": CIELabFromRGB(100, 57, 69, 100),
        "School Bus Yellow": CIELabFromRGB(100, 85, 0, 100),
        "Screamin' Green": CIELabFromRGB(46, 100, 48, 100),
        "Sea Blue": CIELabFromRGB(0, 41, 58, 100),
        "Sea Green": CIELabFromRGB(18, 55, 34, 100),
        "Seal Brown": CIELabFromRGB(20, 8, 8, 100),
        "Seashell": CIELabFromRGB(100, 96, 93, 100),
        "Selective Yellow": CIELabFromRGB(100, 73, 0, 100),
        "Sepia": CIELabFromRGB(44, 26, 8, 100),
        "Shadow": CIELabFromRGB(54, 47, 36, 100),
        "Shadow Blue": CIELabFromRGB(47, 55, 65, 100),
        "Shampoo": CIELabFromRGB(100, 81, 95, 100),
        "Shamrock Green": CIELabFromRGB(0, 62, 38, 100),
        "Sheen Green": CIELabFromRGB(56, 83, 0, 100),
        "Shimmering Blush": CIELabFromRGB(85, 53, 58, 100),
        "Shocking Pink": CIELabFromRGB(99, 6, 75, 100),
        "Shocking Pink (Crayola)": CIELabFromRGB(100, 44, 100, 100),
        "Sienna": CIELabFromRGB(53, 18, 9, 100),
        "Silver": CIELabFromRGB(75, 75, 75, 100),
        "Silver Chalice": CIELabFromRGB(67, 67, 67, 100),
        "Silver Lake Blue": CIELabFromRGB(36, 54, 73, 100),
        "Silver Pink": CIELabFromRGB(77, 68, 68, 100),
        "Silver Sand": CIELabFromRGB(75, 76, 76, 100),
        "Sinopia": CIELabFromRGB(80, 25, 4, 100),
        "Skobeloff": CIELabFromRGB(0, 45, 45, 100),
        "Sky Blue": CIELabFromRGB(53, 81, 92, 100),
        "Sky Magenta": CIELabFromRGB(81, 44, 69, 100),
        "Slate Blue": CIELabFromRGB(42, 35, 80, 100),
        "Slate Gray": CIELabFromRGB(44, 50, 56, 100),
        "Smalt (Dark Powder Blue)": CIELabFromRGB(0, 20, 60, 100),
        "Smitten": CIELabFromRGB(78, 25, 53, 100),
        "Smoke": CIELabFromRGB(45, 51, 46, 100),
        "Smoky Black": CIELabFromRGB(6, 5, 3, 100),
        "Smoky Topaz": CIELabFromRGB(58, 24, 25, 100),
        "Snow": CIELabFromRGB(100, 98, 98, 100),
        "Soap": CIELabFromRGB(81, 78, 94, 100),
        "Solid Pink": CIELabFromRGB(54, 22, 26, 100),
        "Sonic Silver": CIELabFromRGB(46, 46, 46, 100),
        "Spartan Crimson": CIELabFromRGB(62, 7, 9, 100),
        "Space Cadet": CIELabFromRGB(11, 16, 32, 100),
        "Spanish Bistre": CIELabFromRGB(50, 46, 20, 100),
        "Spanish Blue": CIELabFromRGB(0, 44, 72, 100),
        "Spanish Carmine": CIELabFromRGB(82, 0, 28, 100),
        "Spanish Crimson": CIELabFromRGB(90, 10, 30, 100),
        "Spanish Gray": CIELabFromRGB(60, 60, 60, 100),
        "Spanish Green": CIELabFromRGB(0, 57, 31, 100),
        "Spanish Orange": CIELabFromRGB(91, 38, 0, 100),
        "Spanish Pink": CIELabFromRGB(97, 75, 75, 100),
        "Spanish Red": CIELabFromRGB(90, 0, 15, 100),
        "Spanish Sky Blue": CIELabFromRGB(0, 100, 100, 100),
        "Spanish Violet": CIELabFromRGB(30, 16, 51, 100),
        "Spanish Viridian": CIELabFromRGB(0, 50, 36, 100),
        "Spicy Mix": CIELabFromRGB(55, 37, 30, 100),
        "Spiro Disco Ball": CIELabFromRGB(6, 75, 99, 100),
        "Spring Bud": CIELabFromRGB(65, 99, 0, 100),
        "Spring Green": CIELabFromRGB(0, 100, 50, 100),
        "Star Command Blue": CIELabFromRGB(0, 48, 72, 100),
        "Steel Blue": CIELabFromRGB(27, 51, 71, 100),
        "Steel Pink": CIELabFromRGB(80, 20, 80, 100),
        "Stil De Grain Yellow": CIELabFromRGB(98, 85, 37, 100),
        "Stizza": CIELabFromRGB(60, 0, 0, 100),
        "Stormcloud": CIELabFromRGB(31, 40, 42, 100),
        "Thistle": CIELabFromRGB(85, 75, 85, 100),
        "Straw": CIELabFromRGB(89, 85, 44, 100),
        "Strawberry": CIELabFromRGB(99, 35, 55, 100),
        "Sunglow": CIELabFromRGB(100, 80, 20, 100),
        "Sunray": CIELabFromRGB(89, 67, 34, 100),
        "Sunset": CIELabFromRGB(98, 84, 65, 100),
        "Sunset Orange": CIELabFromRGB(99, 37, 33, 100),
        "Super Pink": CIELabFromRGB(81, 42, 66, 100),
        "Tan": CIELabFromRGB(82, 71, 55, 100),
        "Tangelo": CIELabFromRGB(98, 30, 0, 100),
        "Tangerine": CIELabFromRGB(95, 52, 0, 100),
        "Tangerine Yellow": CIELabFromRGB(100, 80, 0, 100),
        "Tango Pink": CIELabFromRGB(89, 44, 48, 100),
        "Taupe": CIELabFromRGB(28, 24, 20, 100),
        "Taupe Gray": CIELabFromRGB(55, 52, 54, 100),
        "Tea Green": CIELabFromRGB(82, 94, 75, 100),
        "Tea Rose": CIELabFromRGB(97, 51, 47, 100),
        "Tea Rosier": CIELabFromRGB(96, 76, 76, 100),
        "Teal": CIELabFromRGB(0, 50, 50, 100),
        "Teal Blue": CIELabFromRGB(21, 46, 53, 100),
        "Teal Deer": CIELabFromRGB(60, 90, 70, 100),
        "Teal Green": CIELabFromRGB(0, 51, 50, 100),
        "Telemagenta": CIELabFromRGB(81, 20, 46, 100),
        "Tenné": CIELabFromRGB(80, 34, 0, 100),
        "Terra Cotta": CIELabFromRGB(89, 45, 36, 100),
        "Thulian Pink": CIELabFromRGB(87, 44, 63, 100),
        "Tickle Me Pink": CIELabFromRGB(99, 54, 67, 100),
        "Tiffany Blue": CIELabFromRGB(4, 73, 71, 100),
        "Tiger's Eye": CIELabFromRGB(88, 55, 24, 100),
        "Timberwolf": CIELabFromRGB(86, 84, 82, 100),
        "Titanium Yellow": CIELabFromRGB(93, 90, 0, 100),
        "Tomato": CIELabFromRGB(100, 39, 28, 100),
        "Toolbox": CIELabFromRGB(45, 42, 75, 100),
        "Topaz": CIELabFromRGB(100, 78, 49, 100),
        "Tractor Red": CIELabFromRGB(99, 5, 21, 100),
        "Trolley Grey": CIELabFromRGB(50, 50, 50, 100),
        "Tropical Rain Forest": CIELabFromRGB(0, 46, 37, 100),
        "True Blue": CIELabFromRGB(0, 45, 81, 100),
        "Tufts Blue": CIELabFromRGB(25, 49, 76, 100),
        "Tulip": CIELabFromRGB(100, 53, 55, 100),
        "Tumbleweed": CIELabFromRGB(87, 67, 53, 100),
        "Turkish Rose": CIELabFromRGB(71, 45, 51, 100),
        "Turquoise": CIELabFromRGB(25, 88, 82, 100),
        "Turquoise Blue": CIELabFromRGB(0, 100, 94, 100),
        "Turquoise Green": CIELabFromRGB(63, 84, 71, 100),
        "Tuscan": CIELabFromRGB(98, 84, 65, 100),
        "Tuscan Brown": CIELabFromRGB(44, 31, 22, 100),
        "Tuscan Red": CIELabFromRGB(49, 28, 28, 100),
        "Tuscan Tan": CIELabFromRGB(65, 48, 36, 100),
        "Tuscany": CIELabFromRGB(75, 60, 60, 100),
        "Twilight Lavender": CIELabFromRGB(54, 29, 42, 100),
        "Tyrian Purple": CIELabFromRGB(40, 1, 24, 100),
        "UA Blue": CIELabFromRGB(0, 20, 67, 100),
        "UA Red": CIELabFromRGB(85, 0, 30, 100),
        "Ube": CIELabFromRGB(53, 47, 76, 100),
        "UCLA Blue": CIELabFromRGB(33, 41, 58, 100),
        "UCLA Gold": CIELabFromRGB(100, 70, 0, 100),
        "UFO Green": CIELabFromRGB(24, 82, 44, 100),
        "Ultramarine": CIELabFromRGB(7, 4, 56, 100),
        "Ultramarine Blue": CIELabFromRGB(25, 40, 96, 100),
        "Ultra Pink": CIELabFromRGB(100, 44, 100, 100),
        "Ultra Red": CIELabFromRGB(99, 42, 52, 100),
        "Umber": CIELabFromRGB(39, 32, 28, 100),
        "Unbleached Silk": CIELabFromRGB(100, 87, 79, 100),
        "United Nations Blue": CIELabFromRGB(36, 57, 90, 100),
        "University Of California Gold": CIELabFromRGB(72, 53, 15, 100),
        "Unmellow Yellow": CIELabFromRGB(100, 100, 40, 100),
        "UP Forest Green": CIELabFromRGB(0, 27, 13, 100),
        "UP Maroon": CIELabFromRGB(48, 7, 7, 100),
        "Upsdell Red": CIELabFromRGB(68, 13, 16, 100),
        "Urobilin": CIELabFromRGB(88, 68, 13, 100),
        "USAFA Blue": CIELabFromRGB(0, 31, 60, 100),
        "USC Cardinal": CIELabFromRGB(60, 0, 0, 100),
        "USC Gold": CIELabFromRGB(100, 80, 0, 100),
        "University Of Tennessee Orange": CIELabFromRGB(97, 50, 0, 100),
        "Utah Crimson": CIELabFromRGB(83, 0, 25, 100),
        "Vanilla": CIELabFromRGB(95, 90, 67, 100),
        "Vanilla Ice": CIELabFromRGB(95, 56, 66, 100),
        "Vegas Gold": CIELabFromRGB(77, 70, 35, 100),
        "Venetian Red": CIELabFromRGB(78, 3, 8, 100),
        "Verdigris": CIELabFromRGB(26, 70, 68, 100),
        "Vermilion": CIELabFromRGB(89, 26, 20, 100),
        "Vermilion 2": CIELabFromRGB(85, 22, 12, 100),
        "Veronica": CIELabFromRGB(63, 13, 94, 100),
        "Very Light Azure": CIELabFromRGB(45, 73, 98, 100),
        "Very Light Blue": CIELabFromRGB(40, 40, 100, 100),
        "Very Light Malachite Green": CIELabFromRGB(39, 91, 53, 100),
        "Very Light Tangelo": CIELabFromRGB(100, 69, 47, 100),
        "Very Pale Orange": CIELabFromRGB(100, 87, 75, 100),
        "Very Pale Yellow": CIELabFromRGB(100, 100, 75, 100),
        "Violet": CIELabFromRGB(56, 0, 100, 100),
        "Violet (Color Wheel)": CIELabFromRGB(50, 0, 100, 100),
        "Violet (RYB)": CIELabFromRGB(53, 0, 69, 100),
        "Violet (Web)": CIELabFromRGB(93, 51, 93, 100),
        "Violet-Blue": CIELabFromRGB(20, 29, 70, 100),
        "Violet-Red": CIELabFromRGB(97, 33, 58, 100),
        "Viridian": CIELabFromRGB(25, 51, 43, 100),
        "Viridian Green": CIELabFromRGB(0, 59, 60, 100),
        "Vista Blue": CIELabFromRGB(49, 62, 85, 100),
        "Vivid Amber": CIELabFromRGB(80, 60, 0, 100),
        "Vivid Auburn": CIELabFromRGB(57, 15, 14, 100),
        "Vivid Burgundy": CIELabFromRGB(62, 11, 21, 100),
        "Vivid Cerise": CIELabFromRGB(85, 11, 51, 100),
        "Vivid Cerulean": CIELabFromRGB(0, 67, 93, 100),
        "Vivid Crimson": CIELabFromRGB(80, 0, 20, 100),
        "Vivid Gamboge": CIELabFromRGB(100, 60, 0, 100),
        "Vivid Lime Green": CIELabFromRGB(65, 84, 3, 100),
        "Vivid Malachite": CIELabFromRGB(0, 80, 20, 100),
        "Vivid Mulberry": CIELabFromRGB(72, 5, 89, 100),
        "Vivid Orange": CIELabFromRGB(100, 37, 0, 100),
        "Vivid Orange Peel": CIELabFromRGB(100, 63, 0, 100),
        "Vivid Orchid": CIELabFromRGB(80, 0, 100, 100),
        "Vivid Raspberry": CIELabFromRGB(100, 0, 42, 100),
        "Vivid Red": CIELabFromRGB(97, 5, 10, 100),
        "Vivid Red-Tangelo": CIELabFromRGB(87, 38, 14, 100),
        "Vivid Sky Blue": CIELabFromRGB(0, 80, 100, 100),
        "Vivid Tangelo": CIELabFromRGB(94, 45, 15, 100),
        "Vivid Tangerine": CIELabFromRGB(100, 63, 54, 100),
        "Vivid Vermilion": CIELabFromRGB(90, 38, 14, 100),
        "Vivid Violet": CIELabFromRGB(62, 0, 100, 100),
        "Vivid Yellow": CIELabFromRGB(100, 89, 1, 100),
        "Warm Black": CIELabFromRGB(0, 26, 26, 100),
        "Waterspout": CIELabFromRGB(64, 96, 98, 100),
        "Wenge": CIELabFromRGB(39, 33, 32, 100),
        "Wheat": CIELabFromRGB(96, 87, 70, 100),
        "White": CIELabFromRGB(100, 100, 100, 100),
        "White Smoke": CIELabFromRGB(96, 96, 96, 100),
        "Wild Blue Yonder": CIELabFromRGB(64, 68, 82, 100),
        "Wild Orchid": CIELabFromRGB(83, 44, 64, 100),
        "Wild Strawberry": CIELabFromRGB(100, 26, 64, 100),
        "Wild Watermelon": CIELabFromRGB(99, 42, 52, 100),
        "Willpower Orange": CIELabFromRGB(99, 35, 0, 100),
        "Windsor Tan": CIELabFromRGB(65, 33, 1, 100),
        "Wine": CIELabFromRGB(45, 18, 22, 100),
        "Wine Dregs": CIELabFromRGB(40, 19, 28, 100),
        "Wisteria": CIELabFromRGB(79, 63, 86, 100),
        "Wood Brown": CIELabFromRGB(76, 60, 42, 100),
        "Xanadu": CIELabFromRGB(45, 53, 47, 100),
        "Yale Blue": CIELabFromRGB(6, 30, 57, 100),
        "Yankees Blue": CIELabFromRGB(11, 16, 25, 100),
        "Yellow": CIELabFromRGB(100, 100, 0, 100),
        "Yellow (Crayola)": CIELabFromRGB(99, 91, 51, 100),
        "Yellow (Munsell)": CIELabFromRGB(94, 80, 0, 100),
        "Yellow (NCS)": CIELabFromRGB(100, 83, 0, 100),
        "Yellow (Pantone)": CIELabFromRGB(100, 87, 0, 100),
        "Yellow (Process)": CIELabFromRGB(100, 94, 0, 100),
        "Yellow (RYB)": CIELabFromRGB(100, 100, 20, 100),
        "Yellow-Green": CIELabFromRGB(60, 80, 20, 100),
        "Yellow Orange": CIELabFromRGB(100, 68, 26, 100),
        "Yellow Rose": CIELabFromRGB(100, 94, 0, 100),
        "Zaffre": CIELabFromRGB(0, 8, 66, 100),
        "Zinnwaldite Brown": CIELabFromRGB(17, 9, 3, 100),
        "Zomp": CIELabFromRGB(22, 65, 56, 100)
    ]
}
