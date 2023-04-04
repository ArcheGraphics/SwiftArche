//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Dynamic Coding Key Object
public struct SerializedCodingKeys: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init(key: String) {
        stringValue = key
    }

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        stringValue = String(intValue)
    }
}
