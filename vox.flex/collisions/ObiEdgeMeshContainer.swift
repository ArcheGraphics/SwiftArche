//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct Edge: IBounded {
    public var i1: Int
    public var i2: Int

    var b: Aabb

    public init(i1: Int, i2: Int, v1: Vector2, v2: Vector2) {
        self.i1 = i1
        self.i2 = i2
        b = Aabb(point: Vector4(v1.x, v1.y, 0, 0))
        b.Encapsulate(point: Vector4(v2.x, v2.y, 0, 0))
    }

    public func GetBounds() -> Aabb {
        return b
    }
}

public struct EdgeMeshHeader {
    public var firstNode: Int
    public var nodeCount: Int
    public var firstEdge: Int
    public var edgeCount: Int
    public var firstVertex: Int
    public var vertexCount: Int

    public init(firstNode: Int, nodeCount: Int,
                firstTriangle: Int, triangleCount: Int,
                firstVertex: Int, vertexCount: Int)
    {
        self.firstNode = firstNode
        self.nodeCount = nodeCount
        firstEdge = firstTriangle
        edgeCount = triangleCount
        self.firstVertex = firstVertex
        self.vertexCount = vertexCount
    }
}
