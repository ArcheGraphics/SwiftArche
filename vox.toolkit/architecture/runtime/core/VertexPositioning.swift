//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// A set of commonly used functions for modifying mesh positions.
public class VertexPositioning {
    static var s_CoincidentVertices: [Int] = []

    /// Get a copy of a mesh positions array transformed into world coordinates.
    /// - Parameter mesh: The source mesh.
    /// - Returns: An array containing all vertex positions in world space.
    public static func VerticesInWorldSpace(mesh: ProBuilderMesh) -> [Vector3] {
        []
    }

    /// Translate a set of vertices with a world space offset.
    /// Unlike most other mesh operations, this function applies the mesh positions to both ProBuilderMesh and the UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to be affected.
    ///   - indexes: A set of triangles pointing to the vertex positions that are to be affected.
    ///   - offset: The offset to apply in world coordinates.
    public static func TranslateVerticesInWorldSpace(for mesh: ProBuilderMesh, indexes: [Int], offset: Vector3) {
    }

    /// Translate a set of vertices with a world space offset.
    /// Unlike most other mesh operations, this function applies the mesh positions to both ProBuilderMesh and the UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: mesh
    ///   - indexes: A distinct list of vertex indexes.
    ///   - offset: The direction and magnitude to translate selectedTriangles, in world space.
    ///   - snapValue: If > 0 snap each vertex to the nearest on-grid point in world space.
    ///   - snapAxisOnly: If true vertices will only be snapped along the active axis.
    internal static func TranslateVerticesInWorldSpace(for mesh: ProBuilderMesh,
                                                       indexes: [Int],
                                                       offset: Vector3,
                                                       snapValue: Float,
                                                       snapAxisOnly: Bool) {
    }

    /// Translate a set of vertices with an offset provided in local (model) coordinates.
    /// Unlike most other mesh operations, this function applies the mesh positions to both ProBuilderMesh and the UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to be affected.
    ///   - indexes: A set of triangles pointing to the vertex positions that are to be affected.
    ///   - offset: offset
    public static func TranslateVertices<T: Sequence<Int>>(for mesh: ProBuilderMesh, indexes: T, offset: Vector3) {
    }

    /// Translate a set of vertices with an offset provided in local (model) coordinates.
    /// Unlike most other mesh operations, this function applies the mesh positions to both ProBuilderMesh and the UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to be affected.
    ///   - edges: A set of edges that are to be affected.
    ///   - offset: offset
    public static func TranslateVertices<T: Sequence<Edge>>(for mesh: ProBuilderMesh, edges: T, offset: Vector3) {
    }

    /// Translate a set of vertices with an offset provided in local (model) coordinates.
    /// Unlike most other mesh operations, this function applies the mesh positions to both ProBuilderMesh and the UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to be affected.
    ///   - faces: A set of faces that are to be affected.
    ///   - offset: offset
    public static func TranslateVertices<T: Sequence<Face>>(for mesh: ProBuilderMesh, faces: T, offset: Vector3) {
    }

    static func TranslateVerticesInternal<T: Sequence<Int>>(for mesh: ProBuilderMesh, indices: T, offset: Vector3) {
    }

    /// Given a shared vertex index (index of the triangle in the sharedIndexes array), move all vertices to new position.
    /// Position is in model space coordinates.
    /// Use @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes" and IntArrayUtility.IndexOf to get a shared (or common) index.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - sharedVertexHandle: The shared (or common) index to set the vertex position of.
    ///   - position: The new position in model coordinates.
    public static func SetSharedVertexPosition(for mesh: ProBuilderMesh, sharedVertexHandle: Int, position: Vector3) {
    }

    /// Set a collection of mesh attributes with a Vertex.
    /// Use @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes" and IntArrayUtility.IndexOf to get a shared (or common) index.
    internal static func SetSharedVertexValues(for mesh: ProBuilderMesh, sharedVertexHandle: Int, vertex: Vertex) {
    }
}
