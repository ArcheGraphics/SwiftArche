//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Methods for merging and splitting common (or shared) vertices.
public class VertexEditing {
    /// Collapses all passed indexes to a single shared index.
    /// - Remark:
    ///  Retains vertex normals.
    /// - Parameters:
    ///   - mesh: Target mesh.
    ///   - indexes: The indexes to merge to a single shared vertex.
    ///   - collapseToFirst: If true, instead of merging all vertices to the average position, the vertices will be collapsed onto the first vertex position.
    /// - Returns: The first available local index created as a result of the merge. -1 if action is unsuccessfull.
    public static func MergeVertices(mesh: ProBuilderMesh, indexes: [Int], collapseToFirst: Bool = false) -> Int {
        0
    }

    /// Split the vertices referenced by edge from their shared indexes so that each vertex moves independently.
    /// - Remark:
    /// This is equivalent to calling `SplitVertices(mesh, new int[] { edge.x, edge.y })`.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - edge: The edge to query for vertex indexes.
    public static func SplitVertices(mesh: ProBuilderMesh, edge: Edge) {

    }

    /// Split vertices from their shared indexes so that each vertex moves independently.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - vertices: A list of vertex indexes to split.
    public static func SplitVertices<T: Sequence<Int>>(mesh: ProBuilderMesh, vertices: T) {

    }

    /// Similar to Merge vertices, expect that this method only collapses vertices within a specified distance of one another (typically Mathf.Epsilon is used).
    /// - Parameters:
    ///   - mesh: Target pb_Object.
    ///   - indexes: The vertex indexes to be scanned for inclusion. To weld the entire object for example, pass pb.faces.SelectMany(x => x.indexes).
    ///   - neighborRadius: The minimum distance from another vertex to be considered within welding distance.
    /// - Returns: The indexes of any new vertices created by a weld.
    public static func WeldVertices<T: Sequence<Int>>(mesh: ProBuilderMesh, indexes: T, neighborRadius: Float) -> [Int] {
        []
    }

    /// Split a common index on a face into two vertices and slide each vertex backwards along it's feeding edge by distance.
    /// This method does not perform any input validation, so make sure edgeAndCommonIndex is distinct and all winged edges belong
    /// to the same face.
    ///<pre>
    /// `appendedVertices` is common index and a list of the new face indexes it was split into.
    ///
    /// _ _ _ _          _ _ _
    /// |              /
    /// |         ->   |
    /// |              |
    /// </pre>
    internal static func ExplodeVertex(vertices: [Vertex],
                                       edgeAndCommonIndex: [(WingedEdge, Int)],
                                       distance: Float,
                                       appendedVertices: inout [Int: [Int]]) -> FaceRebuildData {
        FaceRebuildData()
    }

    static func AlignEdgeWithDirection(edge: EdgeLookup, commonIndex: Int) -> Edge {
        Edge(0, 0)
    }

}
