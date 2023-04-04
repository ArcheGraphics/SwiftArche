//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Sub-mesh, mainly contains drawing information.
public class SubMesh {
    /// Start drawing offset.
    public var start: Int = 0
    /// Drawing count.
    public var count: Int = 0
    /// Drawing topology.
    public var topology: MTLPrimitiveType = .triangle

    public init(_ start: Int, _ count: Int, _ topology: MTLPrimitiveType) {
        self.start = start
        self.count = count
        self.topology = topology
    }
}
