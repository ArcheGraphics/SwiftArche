//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BIHNode {
    /// index of the first child node. The second one is right after the first.
    public var firstChild: Int
    /// index of the first element in this node.
    public var start: Int
    /// amount of elements in this node.
    public var count: Int

    /// axis of the split plane (0,1,2 = x,y,z)
    public var axis: Int
    /// minimum split plane
    public var min: Float
    /// maximum split plane
    public var max: Float

    public init(start: Int, count: Int) {
        firstChild = -1
        self.start = start
        self.count = count
        axis = 0
        min = -Float.greatestFiniteMagnitude
        max = Float.greatestFiniteMagnitude
    }
}
