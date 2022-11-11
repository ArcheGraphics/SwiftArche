//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

/// Common utility methods for math operations.
public class MathUtil {
    /// The value for which all absolute numbers smaller than are considered equal to zero.
    public static let zeroTolerance: Float = 1e-5
    /// The conversion factor that radian to degree.
    public static let radToDegreeFactor: Float = 180 / Float.pi
    /// The conversion factor that degree to radian.
    public static let degreeToRadFactor: Float = Float.pi / 180

    /// Checks if a and b are almost equals.
    /// The absolute value of the difference between a and b is close to zero.
    /// - Parameters:
    ///   - a: The left value to compare
    ///   - b: The right value to compare
    /// - Returns: True if a almost equal to b, false otherwise
    public static func equals(_ a: Float, _ b: Float) -> Bool {
        abs(a - b) <= MathUtil.zeroTolerance
    }

    /// Determines whether the specified v is pow2.
    /// - Parameter v: The specified v
    /// - Returns: True if the specified v is pow2, false otherwise
    public static func isPowerOf2(_ v: Int) -> Bool {
        (v & (v - 1)) == 0
    }

    /// Modify the specified r from radian to degree.
    /// - Parameter r: The specified r
    /// - Returns: The degree value
    public static func radianToDegree(_ r: Float) -> Float {
        r * MathUtil.radToDegreeFactor
    }

    /// Modify the specified d from degree to radian.
    /// - Parameter d: The specified d
    /// - Returns: The radian value
    public static func degreeToRadian(_ d: Float) -> Float {
        d * MathUtil.degreeToRadFactor
    }
}
