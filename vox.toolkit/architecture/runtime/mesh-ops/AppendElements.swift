//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Functions for appending elements to meshes.
public class AppendElements {
    /// Append a new face to the ProBuilderMesh.
    /// - Parameters:
    ///   - mesh: The mesh target.
    ///   - positions: The new vertex positions to add.
    ///   - colors: The new colors to add (must match positions length).
    ///   - uv0s: The new uvs to add (must match positions length).
    ///   - uv2s: The new uvs to add (must match positions length).
    ///   - uv3s: The new uvs to add (must match positions length).
    ///   - face: A face with the new triangle indexes. The indexes should be 0 indexed.
    ///   - common: common
    /// - Returns: The new face as referenced on the mesh.
    internal static func AppendFace(mesh: ProBuilderMesh,
                                    positions: [Vector3],
                                    colors: [Color],
                                    uv0s: [Vector2],
                                    uv2s: [Vector4],
                                    uv3s: [Vector4],
                                    face: Face,
                                    common: [Int]) -> Face {
        Face()
    }

    /// Append a group of new faces to the mesh. Significantly faster than calling AppendFace multiple times.
    /// - Parameters:
    ///   - mesh: The source mesh to append new faces to.
    ///   - positions: An array of position arrays, where indexes correspond to the appendedFaces parameter.
    ///   - colors: An array of colors arrays, where indexes correspond to the appendedFaces parameter.
    ///   - uvs: An array of uvs arrays, where indexes correspond to the appendedFaces parameter.
    ///   - faces: An array of faces arrays, which contain the triangle winding information for each new face. Face index values are 0 indexed.
    ///   - shared: An optional mapping of each new vertex's common index.
    ///   Common index refers to a triangle's index in the @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes" array.
    ///   If this value is provided, it must contain entries for each vertex position. Ex,
    ///   if there are 4 vertices in this face, there must be shared index entries for { 0, 1, 2, 3 }.
    /// - Returns: An array of the new faces that where successfully appended to the mesh.
    public static func AppendFaces(mesh: ProBuilderMesh,
                                   positions: [[Vector3]],
                                   colors: [[Color]],
                                   uvs: [[Vector2]],
                                   faces: [[Face]],
                                   shared: [[Int]]) -> [Face] {
        []
    }

    /// Create a new face connecting existing vertices.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - indexes: The indexes of the vertices to join with the new polygon.
    ///   - unordered: Are the indexes in an ordered path (false), or not (true)?
    ///   If indexes are not ordered this function will treat the polygon as a convex shape.
    ///   Ordered paths will be triangulated allowing concave shapes.
    /// - Returns: The new face created if the action was successfull, null if action failed.
    public static func CreatePolygon(mesh: ProBuilderMesh, indexes: [Int], unordered: Bool) -> Face {
        Face()
    }

    /// Create a new face connecting existing vertices.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - indexes: The indexes of the vertices to join with the new polygon.
    ///   - holes: A list of index lists defining holes.
    /// - Returns: The new face created if the action was successful, null if action failed.
    public static func CreatePolygonWithHole(mesh: ProBuilderMesh, indexes: [Int], holes: [[Int]]) -> Face {
        Face()
    }
    
    /// Create a poly shape from a set of points on a plane. The points must be ordered.
    /// - Parameter poly: The <see cref="PolyShape"/> component to rebuild.
    /// - Returns: An action result indicating the status of the operation.
    public static func CreateShapeFromPolygon(_ poly: PolyShape) -> ActionResult {
        ActionResult.Success
    }

    /// Clear and refresh mesh in case of failure to create a shape.
    internal static func ClearAndRefreshMesh(_ mesh: ProBuilderMesh) {
    }

    /// Rebuild a mesh from an ordered set of points.
    /// - Parameters:
    ///   - mesh: The target mesh. The mesh values will be cleared and repopulated with the shape extruded from points.
    ///   - points: A path of points to triangulate and extrude.
    ///   - extrude: The distance to extrude.
    ///   - flipNormals: If true the faces will be inverted at creation.
    /// - Returns: An ActionResult with the status of the operation.
    public static func CreateShapeFromPolygon(mesh: ProBuilderMesh, points: [Vector3],
                                              extrude: Float, flipNormals: Bool) -> ActionResult {
        ActionResult.Success
    }
    
    /// Rebuild a mesh from an ordered set of points.
    /// - Parameters:
    ///   - mesh: The target mesh. The mesh values will be cleared and repopulated with the shape extruded from points.
    ///   - points: A path of points to triangulate and extrude.
    ///   - extrude: The distance to extrude.
    ///   - flipNormals: If true the faces will be inverted at creation.
    ///   - cameraLookAt: This argument is now ignored.
    ///   - holePoints: Holes in the polygon.
    /// - Returns: An ActionResult with the status of the operation.
    public static func CreateShapeFromPolygon(mesh: ProBuilderMesh, points: [Vector3], extrude: Float,
                                              flipNormals: Bool, cameraLookAt: Vector3,
                                              holePoints: [[Vector3]]? = nil) -> ActionResult {
        ActionResult.Success
    }

    /// Rebuild a mesh from an ordered set of points.
    /// - Parameters:
    ///   - mesh: The target mesh. The mesh values will be cleared and repopulated with the shape extruded from points.
    ///   - points: A path of points to triangulate and extrude.
    ///   - extrude: The distance to extrude.
    ///   - flipNormals: If true the faces will be inverted at creation.
    ///   - holePoints: Holes in the polygon. If null this will be ignored.
    /// - Returns: An ActionResult with the status of the operation.
    public static func CreateShapeFromPolygon(mesh: ProBuilderMesh, points: [Vector3],
                                              extrude: Float, flipNormals: Bool, holePoints: [[Vector3]]) -> ActionResult {
        ActionResult.Success
    }

    /// Create a new face given a set of unordered vertices (or ordered, if unordered param is set to false).
    internal static func FaceWithVertices(_ vertices: [Vertex], unordered: Bool = true) -> FaceRebuildData {
        FaceRebuildData()
    }

    /// Create a new face given a set of ordered vertices and vertices making holes in the face.
    internal static func FaceWithVerticesAndHole(borderVertices: [Vertex], holes: [[Vertex]]) -> FaceRebuildData {
        FaceRebuildData()
    }

    /// Given a path of vertices, inserts a new vertex in the center inserts triangles along the path.
    internal static func TentCapWithVertices(path: [Vertex]) -> [FaceRebuildData] {
        []
    }

    /// <summary>
    /// Duplicate and reverse the winding direction for each face.
    /// </summary>
    /// <param name="mesh">The target mesh.</param>
    /// <param name="faces">The faces to duplicate, reverse triangle winding order, and append to mesh.</param>
    public static func DuplicateAndFlip(mesh: ProBuilderMesh, faces: [Face]) {

    }

    /// Insert a face between two edges.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - a: First edge.
    ///   - b: Second edge.
    ///   - allowNonManifoldGeometry: If true, this function will allow edges to be bridged that create overlapping (non-manifold) faces.
    /// - Returns: The new face, or null of the action failed.
    public static func Bridge(mesh: ProBuilderMesh, a: Edge, b: Edge, allowNonManifoldGeometry: Bool = false) -> Face {
        Face()
    }

    /// backwards compatibility prevents us from just using insertOnEdge as an optional parameter
    public static func AppendVerticesToFace(mesh: ProBuilderMesh, face: Face, points: [Vector3]) -> Face {
        Face()
    }

    /// Add a set of points to a face and re-triangulate. Points are added to the nearest edge.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - face: The face to append points to.
    ///   - points: Points to added to the face.
    ///   - insertOnEdge: True to force new points to edges.
    /// - Returns: The face created by appending the points.
    public static func AppendVerticesToFace(mesh: ProBuilderMesh, face: Face, points: [Vector3], insertOnEdge: Bool) -> Face {
        Face()
    }

    /// Insert a number of new points to an edge. Points are evenly spaced out along the edge.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - edge: The edge to split with points.
    ///   - count: The number of new points to insert. Must be greater than 0.
    /// - Returns: The new edges created by inserting points.
    public static func AppendVerticesToEdge(mesh: ProBuilderMesh, edge: Edge, count: Int) -> [Edge] {
        []
    }

    /// Insert a number of new points to each edge. Points are evenly spaced out along the edge.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - edges: The edges to split with points.
    ///   - count: The number of new points to insert. Must be greater than 0.
    /// - Returns: The new edges created by inserting points.
    public static func AppendVerticesToEdge(mesh: ProBuilderMesh, edges: [Edge], count: Int) -> [Edge] {
        []
    }

    /// Add a set of points to a face and retriangulate. Points are added to the nearest edge.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - face: The face to append points to.
    ///   - point: Point to added to the face.
    /// - Returns: The face created by appending the points.
    public static func InsertVertexInFace(mesh: ProBuilderMesh, face: Face, point: Vector3) -> [Face] {
        []
    }

    /// Insert a number of new points to each edge. Points are evenly spaced out along the edge.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - originalEdge: The edge on which adding the point.
    ///   - point: The point to insert on the edge.
    /// - Returns: The new edges created by the point insertion.
    public static func InsertVertexOnEdge(mesh: ProBuilderMesh, originalEdge: Edge, point: Vector3) -> Vertex {
        Vertex()
    }

    /// Add a point to a face.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - point: Point to added to the face.
    ///   - normal: The inserted point normal.
    /// - Returns: The face created by appending the points.
    public static func InsertVertexInMesh(_ mesh: ProBuilderMesh, point: Vector3, normal: Vector3) -> Vertex {
        Vertex()
    }
}
