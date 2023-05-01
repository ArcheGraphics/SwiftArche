//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct UpdateNormalsJob {
    public private(set) var deformableTriangles: [Int]
    public private(set) var renderPositions: [float4]
    public var normals: [float4]

    public func Execute() {}
}
