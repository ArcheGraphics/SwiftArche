//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for removing vertices and triangles from a mesh.
public enum DeleteElements {
    /// Deletes the vertices from the passed index array, and handles rebuilding the sharedIndexes array.
    /// - Remark
    /// This function does not retriangulate the mesh. Ie, you are responsible for ensuring that indexes
    /// deleted by this function are not referenced by any triangles.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - distinctIndexes: A list of vertices to delete. Note that this must not contain duplicates.
    public static func DeleteVertices<T: Sequence<Int>>(mesh _: ProBuilderMesh, distinctIndexes _: T) {}

    /// Removes a face from a mesh.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - face: The face to remove.
    /// - Returns: An array of vertex indexes that were deleted as a result of face deletion.
    public static func DeleteFace(mesh _: ProBuilderMesh, face _: Face) -> [Int] {
        []
    }

    /// Delete a collection of faces from a mesh.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to remove.
    /// - Returns: An array of vertex indexes that were deleted as a result of deletion.
    public static func DeleteFaces<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T) -> [Int] {
        []
    }

    /// Delete a collection of faces from a mesh.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faceIndexes: The indexes of faces to remove (corresponding to the @"UnityEngine.ProBuilder.ProBuilderMesh.faces" collection.
    /// - Returns: An array of vertex indexes that were deleted as a result of deletion.
    public static func DeleteFaces(mesh _: ProBuilderMesh, faceIndexes _: [Int]) -> [Int] {
        []
    }
}
