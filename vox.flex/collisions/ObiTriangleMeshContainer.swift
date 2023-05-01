//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

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

public class ObiTriangleMeshHandle: ObiResourceHandle<ModelMesh> {
    public init(mesh: ModelMesh, index: Int = -1) {
        super.init(index: index)
        owner = mesh
    }
}

public struct TriangleMeshHeader // we need to use the header in the backend, so it must be a struct.
{
    public var firstNode: Int
    public var nodeCount: Int
    public var firstTriangle: Int
    public var triangleCount: Int
    public var firstVertex: Int
    public var vertexCount: Int

    public init(firstNode: Int, nodeCount: Int, firstTriangle: Int, triangleCount: Int, firstVertex: Int, vertexCount: Int)
    {
        self.firstNode = firstNode
        self.nodeCount = nodeCount
        self.firstTriangle = firstTriangle
        self.triangleCount = triangleCount
        self.firstVertex = firstVertex
        self.vertexCount = vertexCount
    }
}

public class ObiTriangleMeshContainer {
    /// dictionary indexed by mesh, so that we don't generate data for the same mesh multiple times.
//    public var handles: [Mesh: ObiTriangleMeshHandle] = [:]

    /// One header per mesh.
    public var headers: [TriangleMeshHeader] = []
    public var bihNodes: [BIHNode] = []
    public var triangles: [Triangle] = []
    public var vertices: [Vector3] = []

    public init() {}
}
