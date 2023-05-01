//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiDistanceField: NSObject {
    private var input: ModelMesh?

    private var minNodeSize: Float = 0
    private var bounds: Bounds = .init()
    /// list of distance field nodes
    public var nodes: [DFNode] = []

    public var maxError: Float = 0.01

    public var maxDepth = 5
}
