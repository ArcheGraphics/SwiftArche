//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Layer, used for bit operations.
public struct Layer: OptionSet {
    public let rawValue: UInt

    // this initializer is required, but it's also automatically
    // synthesized if `rawValue` is the only member, so writing it
    // here is optional:
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Layer 0.
    public static let Layer0 = Layer(rawValue: 0x1)
    /// Layer 1.
    public static let Layer1 = Layer(rawValue: 0x2)
    /// Layer 2.
    public static let Layer2 = Layer(rawValue: 0x4)
    /// Layer 3.
    public static let Layer3 = Layer(rawValue: 0x8)
    /// Layer 4.
    public static let Layer4 = Layer(rawValue: 0x10)
    /// Layer 5.
    public static let Layer5 = Layer(rawValue: 0x20)
    /// Layer 6.
    public static let Layer6 = Layer(rawValue: 0x40)
    /// Layer 7.
    public static let Layer7 = Layer(rawValue: 0x80)
    /// Layer 8.
    public static let Layer8 = Layer(rawValue: 0x100)
    /// Layer 9.
    public static let Layer9 = Layer(rawValue: 0x200)
    /// Layer 10.
    public static let Layer10 = Layer(rawValue: 0x400)
    /// Layer 11.
    public static let Layer11 = Layer(rawValue: 0x800)
    /// Layer 12.
    public static let Layer12 = Layer(rawValue: 0x1000)
    /// Layer 13.
    public static let Layer13 = Layer(rawValue: 0x2000)
    /// Layer 14.
    public static let Layer14 = Layer(rawValue: 0x4000)
    /// Layer 15.
    public static let Layer15 = Layer(rawValue: 0x8000)
    /// Layer 16.
    public static let Layer16 = Layer(rawValue: 0x10000)
    /// Layer 17.
    public static let Layer17 = Layer(rawValue: 0x20000)
    /// Layer 18.
    public static let Layer18 = Layer(rawValue: 0x40000)
    /// Layer 19.
    public static let Layer19 = Layer(rawValue: 0x80000)
    /// Layer 20.
    public static let Layer20 = Layer(rawValue: 0x100000)
    /// Layer 21.
    public static let Layer21 = Layer(rawValue: 0x200000)
    /// Layer 22.
    public static let Layer22 = Layer(rawValue: 0x400000)
    /// Layer 23.
    public static let Layer23 = Layer(rawValue: 0x800000)
    /// Layer 24.
    public static let Layer24 = Layer(rawValue: 0x1000000)
    /// Layer 25.
    public static let Layer25 = Layer(rawValue: 0x2000000)
    /// Layer 26.
    public static let Layer26 = Layer(rawValue: 0x4000000)
    /// Layer 27.
    public static let Layer27 = Layer(rawValue: 0x8000000)
    /// Layer 28.
    public static let Layer28 = Layer(rawValue: 0x1000_0000)
    /// Layer 29.
    public static let Layer29 = Layer(rawValue: 0x2000_0000)
    /// Layer 30.
    public static let Layer30 = Layer(rawValue: 0x4000_0000)
    /// Layer 31.
    public static let Layer31 = Layer(rawValue: 0x8000_0000)
    /// All layers.
    public static let Everything = Layer(rawValue: 0xFFFF_FFFF)
}
