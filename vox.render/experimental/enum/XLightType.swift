//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Layer, used for bit operations.
public struct XLightType: OptionSet {
    public let rawValue: UInt32
    
    // this initializer is required, but it's also automatically
    // synthesized if `rawValue` is the only member, so writing it
    // here is optional:
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Layer 0.
    public static let LightForTransparent = XLightType(rawValue: 0x1)
}
