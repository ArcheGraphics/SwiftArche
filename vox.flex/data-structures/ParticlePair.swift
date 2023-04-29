//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ParticlePair {
    public var first: Int
    public var second: Int

    public init(first: Int, second: Int) {
        self.first = first
        self.second = second
    }

    subscript(index: Int) -> Int {
        get {
            index == 0 ? first : second
        }
        set {
            if index == 0 {
                first = newValue
            } else {
                second = newValue
            }
        }
    }
}
