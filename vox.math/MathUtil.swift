//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import simd

class MathUtil {
    /** The value for which all absolute numbers smaller than are considered equal to zero. */
    static let zeroTolerance: Float = 1e-6;
    /** The conversion factor that radian to degree. */
    static let radToDegreeFactor: Float = 180 / pi;
    /** The conversion factor that degree to radian. */
    static let degreeToRadFactor: Float = pi / 180;
}
