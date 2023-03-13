//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Utilities for working with triangle and quad primitives.
public class SurfaceTopology {
    /// Convert a selection of faces from n-gons to triangles.
    /// If a face is successfully converted to triangles, each new triangle is created as a separate face and the original face is deleted.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - faces: The faces to convert from quads to triangles.
    /// - Returns: Any new triangle faces created by breaking faces into individual triangles.
    public static func ToTriangles(mesh: ProBuilderMesh, faces: [Face]) -> [Face] {
        []
    }

    static func BreakFaceIntoTris(face: Face, vertices: [Vertex], lookup: [Int: Int]) -> [FaceRebuildData] {
        []
    }

    /// Attempt to extract the winding order for a face.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - face: The face to test.
    /// - Returns: The winding order if successfull, unknown if not.
    public static func GetWindingOrder(mesh: ProBuilderMesh, face: Face) -> WindingOrder {
        WindingOrder.Unknown
    }

    static func GetWindingOrder(vertices: [Vertex], indexes: [Int]) -> WindingOrder {
        WindingOrder.Unknown
    }

    /// Return the winding order of a set of ordered points.
    /// - Remark:
    /// http://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order
    /// - Parameter points: A path of points in 2d space.
    /// - Returns: The winding order if found, WindingOrder.Unknown if not.
    public static func GetWindingOrder(points: [Vector2]) -> WindingOrder {
        WindingOrder.Unknown
    }
    
    /// Reverses the orientation of the middle edge in a quad.
    /// <![CDATA[
    /// ```
    /// .  _____        _____
    /// . |\    |      |    /|
    /// . |  \  |  =>  |  /  |
    /// . |____\|      |/____|
    /// ```
    /// ]]>
    /// - Parameters:
    ///   - mesh: The mesh that face belongs to.
    ///   - face: The target face.
    /// - Returns: True if successful, false if not. Operation will fail if face does not contain two triangles with exactly 2 shared vertices.
    public static func FlipEdge(mesh: ProBuilderMesh, face: Face) -> Bool {
        false
    }
    
    /// Ensure that all adjacent face normals are pointing in a uniform direction.
    /// This function supports multiple islands of connected faces, but it may not unify each island the same way.
    /// - Parameters:
    ///   - mesh: The mesh that the faces belong to.
    ///   - faces: The faces to make uniform.
    /// - Returns: The state of the action.
    public static func ConformNormals<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) -> ActionResult {
        ActionResult.Success
    }

    static func GetWindingFlags(edge: WingedEdge, flag: Bool, flags: [Face: Bool]) {

    }


    /// Ensure the opposite face to source matches the winding order.
    internal static func ConformOppositeNormal(source: WingedEdge) -> ActionResult {
        ActionResult.Success
    }

    /// Iterate a face and return a new common edge where the edge indexes are true to the triangle winding order.
    static func GetCommonEdgeInWindingOrder(wing: WingedEdge) -> Edge {
        Edge(0, 0)
    }

    /// Match a target face to the source face. Faces must be adjacent.
    internal static func MatchNormal(source: Face, target: Face, lookup: [Int: Int]) {
    }
}
