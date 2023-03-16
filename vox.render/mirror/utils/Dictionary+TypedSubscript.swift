//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public extension Dictionary where Key == String {
    subscript(string key: String) -> String? {
        return self[key] as? String
    }

    subscript(bool key: String) -> Bool? {
        return self[key] as? Bool
    }

    // MARK: - Numeric

    subscript(int key: String) -> Int? {
        return self[key] as? Int
    }

    subscript(float key: String) -> Float? {
        return self[key] as? Float
    }

    subscript(double key: String) -> Double? {
        return self[key] as? Double
    }
}
