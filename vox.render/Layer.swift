//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Layer, used for bit operations.
public enum Layer: Int {
    /// Layer 0.
    case Layer0 = 0x1
    /// Layer 1.
    case Layer1 = 0x2
    /// Layer 2.
    case Layer2 = 0x4
    /// Layer 3.
    case Layer3 = 0x8
    /// Layer 4.
    case Layer4 = 0x10
    /// Layer 5.
    case Layer5 = 0x20
    /// Layer 6.
    case Layer6 = 0x40
    /// Layer 7.
    case Layer7 = 0x80
    /// Layer 8.
    case Layer8 = 0x100
    /// Layer 9.
    case Layer9 = 0x200
    /// Layer 10.
    case Layer10 = 0x400
    /// Layer 11.
    case Layer11 = 0x800
    /// Layer 12.
    case Layer12 = 0x1000
    /// Layer 13.
    case Layer13 = 0x2000
    /// Layer 14.
    case Layer14 = 0x4000
    /// Layer 15.
    case Layer15 = 0x8000
    /// Layer 16.
    case Layer16 = 0x10000
    /// Layer 17.
    case Layer17 = 0x20000
    /// Layer 18.
    case Layer18 = 0x40000
    /// Layer 19.
    case Layer19 = 0x80000
    /// Layer 20.
    case Layer20 = 0x100000
    /// Layer 21.
    case Layer21 = 0x200000
    /// Layer 22.
    case Layer22 = 0x400000
    /// Layer 23.
    case Layer23 = 0x800000
    /// Layer 24.
    case Layer24 = 0x1000000
    /// Layer 25.
    case Layer25 = 0x2000000
    /// Layer 26.
    case Layer26 = 0x4000000
    /// Layer 27.
    case Layer27 = 0x8000000
    /// Layer 28.
    case Layer28 = 0x10000000
    /// Layer 29.
    case Layer29 = 0x20000000
    /// Layer 30.
    case Layer30 = 0x40000000
    /// Layer 31.
    case Layer31 = 0x80000000
    /// All layers.
    case Everything = 0xffffffff
    /// None layer.
    case Nothing = 0x0
}
