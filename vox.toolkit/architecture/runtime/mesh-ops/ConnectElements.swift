//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Store face rebuild data with indexes to mark which vertices are new.
final class ConnectFaceRebuildData {
    public var faceRebuildData: FaceRebuildData
    public var newVertexIndexes: [Int] = []

    public init(faceRebuildData: FaceRebuildData, newVertexIndexes: [Int]) {
        self.faceRebuildData = faceRebuildData
        self.newVertexIndexes = newVertexIndexes
    }
}

/// Utility class for connecting edges, faces, and vertices.
public enum ConnectElements {
    /// Insert new edges from the center of each edge on a face to a new vertex in the center of the face.
    /// - Parameters:
    ///   - mesh: Target mesh.
    ///   - faces: The faces to poke.
    /// - Returns: The faces created as a result of inserting new edges.
    public static func Connect<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T) -> [Face] {
        []
    }

    /// Insert new edges connecting a set of edges. If a face contains more than 2 edges to be connected,
    /// a new vertex is inserted at the center of the face and each edge is connected to the center point.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - edges: A list of edges to connect.
    /// - Returns: The faces and edges created as a result of inserting new edges.
    public static func Connect<T: Sequence<Edge>>(mesh _: ProBuilderMesh, edges _: T) -> ([Face], [Edge]) {
        ([], [])
    }

    /// Inserts edges connecting a list of indexes.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - indexes: A list of indexes (corresponding to the @"UnityEngine.ProBuilder.ProBuilderMesh.positions" array) to connect with new edges.
    /// - Returns: Because this function may modify the ordering of the positions array, a new array containing the equivalent values of the passed connected indexes is returned.
    public static func Connect(mesh _: ProBuilderMesh, indexes _: [Int]) -> [Int] {
        []
    }

    /// Inserts new edges connecting the passed edges, optionally restricting new edge insertion to faces in faceMask.
    internal static func Connect<T: Sequence<Edge>>(mesh _: ProBuilderMesh,
                                                    edges _: T,
                                                    addedFaces _: inout [Face],
                                                    connections _: inout [Edge],
                                                    returnFaces _: Bool = false,
                                                    returnEdges _: Bool = false,
                                                    faceMask _: Set<Face>? = nil) -> ActionResult
    {
        ActionResult.Success
    }

    /// Accepts a face and set of edges to split on.
    static func ConnectEdgesInFace(
        _: Face,
        a _: WingedEdge,
        b _: WingedEdge,
        vertices _: [Vertex]
    ) -> [ConnectFaceRebuildData] {
        []
    }

    /// Insert a new vertex at the center of a face and connect the center of all edges to it.
    static func ConnectEdgesInFace(
        _: Face,
        edges _: [WingedEdge],
        vertices _: [Vertex]
    ) -> [ConnectFaceRebuildData] {
        []
    }

    static func InsertVertices(face _: Face, edges _: [WingedEdge], vertices _: [Vertex],
                               data _: inout ConnectFaceRebuildData) -> Bool
    {
        false
    }

    static func ConnectIndexesPerFace(face _: Face,
                                      a _: Int,
                                      b _: Int,
                                      vertices _: [Vertex],
                                      lookup _: [Int: Int]) -> [ConnectFaceRebuildData]
    {
        []
    }

    static func ConnectIndexesPerFace(face _: Face,
                                      indexes _: [Int],
                                      vertices _: [Vertex],
                                      lookup _: [Int: Int],
                                      sharedIndexOffset _: Int) -> [ConnectFaceRebuildData]
    {
        []
    }
}
