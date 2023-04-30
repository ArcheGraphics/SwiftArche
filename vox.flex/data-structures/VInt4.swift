//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct VInt4 {
    public var x: Int32
    public var y: Int32
    public var z: Int32
    public var w: Int32

    public init(x: Int32, y: Int32, z: Int32, w: Int32) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

    public init(x: Int32) {
        self.x = x
        y = x
        z = x
        w = x
    }
}
