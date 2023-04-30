//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

/// we need to use the header in the backend, so it must be a struct./
public struct DistanceFieldHeader {
    public var firstNode: Int
    public var nodeCount: Int

    public init(firstNode: Int, nodeCount: Int) {
        self.firstNode = firstNode
        self.nodeCount = nodeCount
    }
}
