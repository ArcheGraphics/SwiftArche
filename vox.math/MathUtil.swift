//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd
import Darwin

/// Common utility methods for math operations.
public class MathUtil {
    /// The value for which all absolute numbers smaller than are considered equal to zero.
    public static let zeroTolerance: Float = 1e-5
    /// The conversion factor that radian to degree.
    public static let radToDegreeFactor: Float = 57.29578
    /// The conversion factor that degree to radian.
    public static let degreeToRadFactor: Float = 0.017453292
    
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

    /// Returns the sine of angle f.
    /// - Parameter f: The input angle, in radians.
    /// - Returns: The return value between -1 and +1.
    public static func sin(_ f: Float) -> Float {
        Float(Darwin.sin(Double(f)))
    }

    /// Returns the cosine of angle f.
    /// - Parameter f: The input angle, in radians.
    /// - Returns: The return value between -1 and 1.
    public static func cos(_ f: Float) -> Float {
        Float(Darwin.cos(Double(f)))
    }

    /// Returns the tangent of angle f in radians.
    public static func tan(_ f: Float) -> Float {
        Float(Darwin.tan(Double(f)))
    }

    /// Returns the arc-sine of f - the angle in radians whose sine is f.
    public static func asin(_ f: Float) -> Float {
        Float(Darwin.asin(Double(f)))
    }

    /// Returns the arc-cosine of f - the angle in radians whose cosine is f.
    public static func acos(_ f: Float) -> Float {
        Float(Darwin.acos(Double(f)))
    }

    /// Returns the arc-tangent of f - the angle in radians whose tangent is f.
    public static func atan(_ f: Float) -> Float {
        Float(Darwin.atan(Double(f)))
    }

    /// Returns the angle in radians whose Tan is y/x.
    public static func atan2(_ y: Float, _ x: Float) -> Float {
        Float(Darwin.atan2(Double(y), Double(x)))
    }

    /// Returns square root of f.
    public static func sqrt(_ f: Float) -> Float {
        Float(Darwin.sqrt(Double(f)))
    }

    /// Returns the absolute value of f.
    public static func abs(_ f: Float) -> Float {
        Swift.abs(f)
    }

    /// Returns the absolute value of value.
    public static func abs(_ value: Int) -> Int {
        Swift.abs(value)
    }

    /// Returns the smallest of two or more values.
    public static func min(_ a: Float, _ b: Float) -> Float {
        Double(a) < Double(b) ? a : b
    }

    /// Returns the smallest of two or more values.
    public static func min(_ a: Int, _ b: Int) -> Int {
        a < b ? a : b
    }

    /// Returns largest of two or more values.
    public static func max(_ a: Float, _ b: Float) -> Float {
        Double(a) > Double(b) ? a : b
    }

    /// Returns the largest of two or more values.
    public static func max(_ a: Int, _ b: Int) -> Int {
        a > b ? a : b
    }

    /// Returns f raised to power p.
    public static func pow(_ f: Float, _ p: Float) -> Float {
        Float(Darwin.pow(Double(f), Double(p)))
    }

    /// Returns e raised to the specified power.
    public static func exp(_ power: Float) -> Float {
        Float(Darwin.exp(Double(power)))
    }

    /// Returns the natural (base e) logarithm of a specified number.
    public static func log(_ f: Float) -> Float {
        Float(Darwin.log(Double(f)))
    }

    /// Returns the base 10 logarithm of a specified number.
    public static func log10(_ f: Float) -> Float {
        Float(Darwin.log10(Double(f)))
    }

    /// Returns the smallest integer greater to or equal to f.
    public static func ceil(_ f: Float) -> Float {
        Float(Darwin.ceil(Double(f)))
    }

    /// Returns the largest integer smaller than or equal to f.
    public static func floor(_ f: Float) -> Float {
        Float(Darwin.floor(Double(f)))
    }

    /// Returns f rounded to the nearest integer.
    public static func round(_ f: Float) -> Float {
        Float(Darwin.round(Double(f)))
    }

    /// Returns the smallest integer greater to or equal to f.
    public static func ceilToInt(_ f: Float) -> Int {
        Int(Darwin.ceil(Double(f)))
    }

    /// Returns the largest integer smaller to or equal to f.
    public static func floorToInt(_ f: Float) -> Int {
        Int(Darwin.floor(Double(f)))
    }

    /// Returns f rounded to the nearest integer.
    public static func roundToInt(_ f: Float) -> Int {
        Int(Darwin.round(Double(f)))
    }

    /// Returns the sign of f.
    public static func sign(_ f: Float) -> Float {
        Double(f) >= 0.0 ? 1: -1
    }

    /// Clamps the given value between the given minimum float and maximum float values.
    /// Returns the given value if it is within the minimum and maximum range.
    /// - Parameters:
    ///   - value: The floating point value to restrict inside the range defined by the minimum and maximum values.
    ///   - min: The minimum floating point value to compare against.
    ///   - max: The maximum floating point value to compare against.
    /// - Returns: The float result between the minimum and maximum values.
    public static func clamp(value: Float, min: Float, max: Float) -> Float {
        var value = value
        if Double(value) < Double(min) {
            value = min
        } else if Double(value) > Double(max) {
            value = max
        }
        return value
    }

    /// Clamps the given value between a range defined by the given minimum integer and maximum integer values.
    /// Returns the given value if it is within min and max.
    /// - Parameters:
    ///   - value: The integer point value to restrict inside the min-to-max range.
    ///   - min: The minimum integer point value to compare against.
    ///   - max: The maximum  integer point value to compare against.
    /// - Returns: The int result between min and max values.
    public static func clamp(value: Int, min: Int, max: Int) -> Int {
        var value = value
        if (value < min) {
            value = min
        } else if (value > max) {
            value = max
        }
        return value
    }

    /// Clamps value between 0 and 1 and returns value.
    public static func clamp01(value: Float) -> Float {
        if Double(value) < 0.0 {
            return 0.0
        }
        return Double(value) > 1.0 ? 1 : value
    }

    /// Linearly interpolates between a and b by t.
    /// - Parameters:
    ///   - a: The start value.
    ///   - b: The end value.
    ///   - t: The interpolation value between the two floats.
    /// - Returns: The interpolated float result between the two float values.
    public static func lerp(a: Float, b: Float, t: Float) -> Float {
        a + (b - a) * MathUtil.clamp01(value: t)
    }

    /// Linearly interpolates between a and b by t with no limit to t.
    /// - Parameters:
    ///   - a: The start value.
    ///   - b: The end value.
    ///   - t: The interpolation between the two floats.
    /// - Returns: The float value as a result from the linear interpolation.
    public static func lerpUnclamped(a: Float, b: Float, t: Float) -> Float {
        a + (b - a) * t
    }

    /// Same as Lerp but makes sure the values interpolate correctly when they wrap around 360 degrees.
    public static func lerpAngle(a: Float, b: Float, t: Float) -> Float {
        var num = MathUtil.repeating(t: b - a, length: 360)
        if Double(num) > 180.0 {
            num -= 360
        }
        return a + num * MathUtil.clamp01(value: t)
    }

    /// Moves a value current towards target.
    /// - Parameters:
    ///   - current: The current value.
    ///   - target: The value to move towards.
    ///   - maxDelta: The maximum change that should be applied to the value.
    public static func moveTowards(current: Float, target: Float, maxDelta: Float) -> Float {
        Double(MathUtil.abs(target - current)) <= Double(maxDelta) ? target : current + MathUtil.sign(target - current) * maxDelta
    }

    /// Same as MoveTowards but makes sure the values interpolate correctly when they wrap around 360 degrees.
    public static func moveTowardsAngle(current: Float, target: Float, maxDelta: Float) -> Float {
        let num = MathUtil.deltaAngle(current: current, target: target)
        if -Double(maxDelta) < Double(num) && Double(num) < Double(maxDelta) {
            return target
        }
        let target = current + num
        return MathUtil.moveTowards(current: current, target: target, maxDelta: maxDelta)
    }

    /// Interpolates between min and max with smoothing at the limits.
    public static func smoothStep(from: Float, to: Float, t: Float) -> Float {
        var t = MathUtil.clamp01(value: t)
        t = Float(-2.0 * Double(t) * Double(t) * Double(t) + 3.0 * Double(t) * Double(t))
        return Float(Double(to) * Double(t) + Double(from) * (1.0 - Double(t)))
    }


    public static func smoothDamp(current: Float,
                                  target: Float,
                                  currentVelocity: inout Float,
                                  smoothTime: Float,
                                  deltaTime: Float,
                                  maxSpeed: Float = Float.infinity) -> Float {
        let smoothTime = MathUtil.max(0.0001, smoothTime)
        let num1: Float = 2.0 / smoothTime
        let num2: Float = num1 * deltaTime
        let num3: Float = Float(1.0 / (1.0 + Double(num2) + 0.47999998927116394 * Double(num2) * Double(num2)
                + 0.23499999940395355 * Double(num2) * Double(num2) * Double(num2)))
        let num4: Float = current - target
        let num5: Float = target
        let maxValue = maxSpeed * smoothTime
        let num6: Float = MathUtil.clamp(value: num4, min: -maxValue, max: maxValue)
        let target = current - num6
        let num7: Float = (currentVelocity + num1 * num6) * deltaTime
        currentVelocity = (currentVelocity - num1 * num7) * num3
        var num8: Float = target + (num6 + num7) * num3
        if (Double(num5) - Double(current) > 0.0) == (Double(num8) > Double(num5)) {
            num8 = num5
            currentVelocity = (num8 - num5) / deltaTime
        }
        return num8
    }


    public static func smoothDampAngle(current: Float,
                                       target: Float,
                                       currentVelocity: inout Float,
                                       smoothTime: Float,
                                       deltaTime: Float,
                                       maxSpeed: Float = Float.infinity) -> Float {
        let target = current + MathUtil.deltaAngle(current: current, target: target)
        return MathUtil.smoothDamp(current: current, target: target, currentVelocity: &currentVelocity,
                smoothTime: smoothTime, deltaTime: deltaTime, maxSpeed: maxSpeed)
    }

    /// Loops the value t, so that it is never larger than length and never smaller than 0.
    public static func repeating(t: Float, length: Float) -> Float {
        MathUtil.clamp(value: t - MathUtil.floor(t / length) * length, min: 0.0, max: length)
    }

/// PingPong returns a value that will increment and decrement between the value 0 and length.
    public static func pingPong(t: Float, length: Float) -> Float {
        let t = MathUtil.repeating(t: t, length: length * 2)
        return length - MathUtil.abs(t - length)
    }

/// Determines where a value lies between two points.
/// - Parameters:
///   - a: The start of the range.
///   - b: The end of the range.
///   - value: The point within the range you want to calculate.
/// - Returns: A value between zero and one, representing where the "value" parameter falls within the range defined by a and b.
    public static func inverseLerp(a: Float, b: Float, value: Float) -> Float {
        Double(a) != Double(b) ? MathUtil.clamp01(value: Float((Double(value) - Double(a)) / (Double(b) - Double(a)))) : 0.0
    }

/// Calculates the shortest difference between two given angles given in degrees.
    public static func deltaAngle(current: Float, target: Float) -> Float {
        var num = MathUtil.repeating(t: target - current, length: 360)
        if (Double(num) > 180.0) {
            num -= 360
        }
        return num
    }

}
