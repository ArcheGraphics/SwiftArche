//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Face and edge extrusion.
public class ExtrudeElements {
    /// Extrude a collection of faces.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to extrude.
    ///   - method: Describes how faces are extruded.
    ///   - distance: The distance to extrude faces.
    /// - Returns: An array of the faces created as a result of the extrusion. Null if the faces paramater is null or empty.
    public static func Extrude<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T,
                                                  method: ExtrudeMethod, distance: Float) -> [Face] {
        []
    }
    
    /// Extrude a collection of edges.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - edges: The edges to extrude.
    ///   - distance: The distance to extrude.
    ///   - extrudeAsGroup: If true adjacent edges will be extruded retaining a shared vertex, if false the shared vertex will be split.
    ///   - enableManifoldExtrude: Pass true to allow this function to extrude manifold edges, false to disallow.
    /// - Returns: The extruded edges, or null if the action failed due to manifold check or an empty edges parameter.
    public static func Extrude<T: Sequence<Edge>>(mesh: ProBuilderMesh, edges: T, distance: Float,
                                                  extrudeAsGroup: Bool, enableManifoldExtrude: Bool) -> [Edge] {
        []
    }

    /// Split any shared vertices so that this face may be moved independently of the main object.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to split from the mesh.
    /// - Returns: The faces created forming the detached face group.
    public static func DetachFaces<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) -> [Face] {
        []
    }

    /// Split any shared vertices so that this face may be moved independently of the main object.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to split from the mesh.
    ///   - deleteSourceFaces: Whether or not to delete the faces on the source geometry which were detached.
    /// - Returns: The faces created forming the detached face group.
    public static func DetachFaces<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T, deleteSourceFaces: Bool) -> [Face] {
        []
    }

    /// Extrude each face in faces individually along it's normal by distance.
    static func ExtrudePerFace<T: Sequence<Face>>(pb: ProBuilderMesh, faces: T, distance: Float) -> [Face] {
        []
    }

    /// Extrude faces as groups.
    static func ExtrudeAsGroups<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T,
                                                   compensateAngleVertexDistance: Bool, distance: Float) -> [Face] {
        []
    }

    static func GetFaceGroups(wings: [WingedEdge]) -> [Set<Face>] {
        []
    }


    static func GetPerimeterEdges(faces: Set<Face>, lookup: [Int: Int]) -> Dictionary<EdgeLookup, Face> {
        [:]
    }

}
     
