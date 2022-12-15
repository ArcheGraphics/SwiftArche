//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

// MARK:- Pi

/// Float-type pi.
public let kPiF: Float = 3.14159265358979323846264338327950288

/// Pi for type T.
/// - Returns: Pi
public func pi() -> Float {
    return kPiF
}

// MARK:- Pi/2

/// Float-type pi/2.
public let kHalfPiF: Float = 1.57079632679489661923132169163975144

/// Pi/2 for type T.
/// - Returns: Pi/2
public func halfPi() -> Float {
    return kHalfPiF
}

// MARK:- Pi/4

/// Float-type pi/4.
public let kQuarterPiF: Float = 0.785398163397448309615660845819875721

/// Pi/4 for type T.
/// - Returns: Pi/4
public func quarterPi() -> Float {
    return kQuarterPiF
}

// MARK:- 2*Pi

/// Float-type 2*pi.
public let kTwoPiF: Float = 2.0 * kPiF

/// 2*pi for type T.
/// - Returns: 2*Pi
public func twoPi() -> Float {
    return kTwoPiF
}

// MARK:- 4*Pi

/// Float-type 4*pi.
public let kFourPiF: Float = 4.0 * kPiF

/// 4*pi for type T.
/// - Returns: 4*Pi
public func fourPi() -> Float {
    return kFourPiF
}

// MARK:- 1/Pi

/// Float-type 1/pi.
public let kInvPiF: Float = 1.0 / kPiF

/// 1/pi for type T.
/// - Returns: 1/pi
public func invPi() -> Float {
    return kInvPiF
}

// MARK:- 1/2*Pi

/// Float-type 1/2*pi.
public let kInvTwoPiF: Float = 0.5 / kPiF

/// 1/2*pi for type T.
/// - Returns: 1/2*pi
public func invTwoPi() -> Float {
    return kInvTwoPiF
}

// MARK:- 1/4*Pi

/// Float-type 1/4*pi.
public let kInvFourPiF: Float = 0.25 / kPiF

/// 1/4*pi for type T.
/// - Returns: 1/4*pi
public func invFourPi() -> Float {
    return kInvFourPiF
}

// MARK:- Physics

//! Gravity.
public let kGravity: Float = -9.8

//! Water density.
public let kWaterDensity: Float = 1000.0

//! Speed of sound in water at 20 degrees celcius.
public let kSpeedOfSoundInWater: Float = 1482.0

// MARK:- Common enums

//! No direction.
public let kDirectionNone: Int = 0

//! Left direction.
public let kDirectionLeft: Int = 1 << 0

//! RIght direction.
public let kDirectionRight: Int = 1 << 1

//! Down direction.
public let kDirectionDown: Int = 1 << 2

//! Up direction.
public let kDirectionUp: Int = 1 << 3

//! Back direction.
public let kDirectionBack: Int = 1 << 4

//! Front direction.
public let kDirectionFront: Int = 1 << 5

//! All direction.
public let kDirectionAll: Int = kDirectionLeft | kDirectionRight |
        kDirectionDown | kDirectionUp | kDirectionBack |
        kDirectionFront
