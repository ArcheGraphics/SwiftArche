//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

public class ObiDistanceFieldHandle: ObiResourceHandle<ObiDistanceField> {
    public init(field: ObiDistanceField, index: Int = -1) {
        super.init(index: index)
        owner = field
    }
}

/// we need to use the header in the backend, so it must be a struct./
public struct DistanceFieldHeader {
    public var firstNode: Int
    public var nodeCount: Int

    public init(firstNode: Int, nodeCount: Int) {
        self.firstNode = firstNode
        self.nodeCount = nodeCount
    }
}

public class ObiDistanceFieldContainer {
    /// dictionary indexed by asset, so that we don't generate data for the same distance field multiple times.
    public var handles: [ObiDistanceField: ObiDistanceFieldHandle] = [:]

    /// One header per distance field.
    public var headers: [DistanceFieldHeader] = []
    public var dfNodes: [DFNode] = []

    public init() {}

    public func DestroyDistanceField(handle _: ObiDistanceFieldHandle) {}
}
