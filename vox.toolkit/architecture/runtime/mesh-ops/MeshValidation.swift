//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Methods for validating and fixing mesh topology.
public enum MeshValidation {
    /// Check if any face on a mesh contains degenerate triangles. A degenerate triangle does not have any area.
    /// - Parameter mesh: The mesh to test for degenerate triangles.
    /// - Returns: True if any face contains a degenerate triangle, false if no degenerate triangles are found.
    public static func ContainsDegenerateTriangles(mesh _: ProBuilderMesh) -> Bool {
        false
    }

    /// Check if any face contains degenerate triangles. A degenerate triangle does not have any area.
    /// - Parameters:
    ///   - mesh: The mesh to test for degenerate triangles.
    ///   - faces: The faces to test for degenerate triangles.
    /// - Returns: True if any face contains a degenerate triangle, false if no degenerate triangles are found.
    public static func ContainsDegenerateTriangles(mesh _: ProBuilderMesh, faces _: [Face]) -> Bool {
        false
    }

    /// Check if any face contains degenerate triangles. A degenerate triangle does not have any area.
    /// - Parameters:
    ///   - mesh: The mesh to test for degenerate triangles.
    ///   - face: The face to test for degenerate triangles.
    /// - Returns: True if any triangle within the face contains a degenerate triangle, false if no degenerate triangles are found.
    public static func ContainsDegenerateTriangles(mesh _: ProBuilderMesh, face _: Face) -> Bool {
        false
    }

    /// Tests that all triangles in a face are connected.
    /// - Parameters:
    ///   - mesh: The mesh that owns the face to be tested.
    ///   - face: The face to test.
    /// - Returns: True if the face contains split triangles, false if the face is contiguous.
    public static func ContainsNonContiguousTriangles(mesh _: ProBuilderMesh, face _: Face) -> Bool {
        false
    }

    /// Ensure that each face in faces is composed of contiguous triangle sets. If a face contains non-contiguous
    /// triangles, it will be split into as many faces as necessary to ensure that each group of adjacent triangles
    /// compose a single face.
    /// - Parameters:
    ///   - mesh: The mesh that contains the faces to test.
    ///   - faces: The faces to test for non-contiguous triangles.
    /// - Returns: A list of any newly created faces as a result of splitting non-contiguous triangles. Returns an
    /// empty list if no faces required fixing.
    public static func EnsureFacesAreComposedOfContiguousTriangles<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T) -> [Face] {
        []
    }

    internal static func CollectFaceGroups(mesh _: ProBuilderMesh, face _: Face) -> [[Triangle]] {
        [[]]
    }

    /// Iterates through all faces in a mesh and removes triangles with an area less than float.Epsilon, or with
    /// indexes that point to the same vertex. This function also enforces the rule that a face must contain no
    /// coincident vertices.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - removed: An optional list to be populated with the removed indices. If no degenerate triangles are found, this list will contain no elements.
    /// - Returns: True if degenerate triangles were found and removed, false if no degenerate triangles were found.
    public static func RemoveDegenerateTriangles(mesh _: ProBuilderMesh, removed _: [Int]? = nil) -> Bool {
        false
    }

    /// Removes vertices that no face references.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - removed: An optional list to be populated with the removed indices. If no vertices are removed, this list will contain no elements.
    /// - Returns: A list of deleted vertex indexes.
    public static func RemoveUnusedVertices(mesh _: ProBuilderMesh, removed _: [Int]? = nil) -> Bool {
        false
    }

    /// Rebuild a collection of indexes accounting for the removal of a collection of indices.
    /// - Parameters:
    ///   - indices: The indices to rebuild.
    ///   - removed: A sorted collection indices that were removed.
    /// - Returns: A new list of indices pointing to the same vertex as they were prior to the removal of some entries.
    internal static func RebuildIndexes<T: Sequence<Int>>(indices _: T, removed _: [Int]) -> [Int] {
        []
    }

    /// Rebuild a collection of indexes accounting for the removal of a collection of indices.
    /// - Parameters:
    ///   - edges: The indices to rebuild.
    ///   - removed: A sorted collection indices that were removed.
    /// - Returns: A new list of indices pointing to the same vertex as they were prior to the removal of some entries.
    internal static func RebuildEdges<T: Sequence<Edge>>(edges _: T, removed _: [Int]) -> [Edge] {
        []
    }

    internal static func RebuildSelectionIndexes<T: Sequence<Int>>(mesh _: ProBuilderMesh,
                                                                   faces _: inout [Face], edges _: inout [Edge],
                                                                   indices _: inout [Int], removed _: T) {}

    /// Check a mesh for degenerate triangles or unused vertices, and remove them if necessary.
    /// - Parameters:
    ///   - mesh: The mesh to test.
    ///   - removedVertices: If fixes were made, this will be set to the number of vertices removed during that process.
    /// - Returns: Returns true if no problems were found, false if topology issues were discovered and fixed.
    internal static func EnsureMeshIsValid(mesh _: ProBuilderMesh, removedVertices _: inout Int) -> Bool {
        false
    }
}
