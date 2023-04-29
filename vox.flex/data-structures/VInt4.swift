//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct VInt4 {
    public var x: Int
    public var y: Int
    public var z: Int
    public var w: Int

    public init(x: Int, y: Int, z: Int, w: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public init(x: Int) {
        self.x = x
        y = x
        z = x
        w = x
    }
}
