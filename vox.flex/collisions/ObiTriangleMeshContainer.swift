//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct Triangle: IBounded {
    public var i1: Int
    public var i2: Int
    public var i3: Int

    var b: Aabb

    public init(i1: Int, i2: Int, i3: Int, v1: Vector3, v2: Vector3, v3: Vector3) {
        self.i1 = i1
        self.i2 = i2
        self.i3 = i3
        b = Aabb(point: Vector4(v1, 0))
        b.Encapsulate(point: Vector4(v2, 0))
        b.Encapsulate(point: Vector4(v3, 0))
    }

    public func GetBounds() -> Aabb {
        return b
    }
}
