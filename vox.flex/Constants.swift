//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Float-type pi/2.
public let kHalfPiF: Float = 1.57079632679489661923132169163975144
/// Float-type pi/4.
public let kQuarterPiF: Float = 0.785398163397448309615660845819875721
/// Float-type 2*pi.
public let kTwoPiF: Float = 2.0 * Float.pi
/// Float-type 4*pi.
public let kFourPiF: Float = 4.0 * Float.pi
/// Float-type 1/pi.
public let kInvPiF: Float = 1.0 / Float.pi
/// Float-type 1/2*pi.
public let kInvTwoPiF: Float = 0.5 / Float.pi
/// Float-type 1/4*pi.
public let kInvFourPiF: Float = 0.25 / Float.pi

// MARK: - Physics

//! Gravity.
public let kGravity: Float = -9.8

//! Water density.
public let kWaterDensity: Float = 1000.0

//! Speed of sound in water at 20 degrees celcius.
public let kSpeedOfSoundInWater: Float = 1482.0

// MARK: - Common enums

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
