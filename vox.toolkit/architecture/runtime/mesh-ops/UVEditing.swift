//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// UV actions.
class UVEditing {
    /// Get a reference to the mesh UV array at index.
    /// - Parameters:
    ///   - mesh: mesh
    ///   - channel: The zero-indexed UV channel.
    /// - Returns: uv
    internal static func GetUVs(mesh: ProBuilderMesh, channel: Int) -> [Vector2] {
        []
    }

    /// Sets an array to the appropriate UV channel, but don't refresh the Mesh.
    internal static func ApplyUVs(mesh: ProBuilderMesh, uvs: [Vector2], channel: Int, applyToMesh: Bool = true) {
    }

    /// Sews (welds) a UV seam using delta to determine which UVs are close enough to be merged.
    public static func SewUVs(mesh: ProBuilderMesh, indexes: [Int], delta: Float) {
    }

    /// Similar to Sew, except Collapse just flattens all UVs to the center point no matter the distance.
    public static func CollapseUVs(mesh: ProBuilderMesh, indexes: [Int]) {
    }

    /// Creates separate entries in shared indexes cache for all passed indexes. If indexes are not present in pb_IntArray[], don't do anything with them.
    public static func SplitUVs<T: Sequence<Int>>(mesh: ProBuilderMesh, indexes: T) {
    }

    /// Creates separate entries in shared indexes cache for all passed indexes.
    internal static func SplitUVs<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) {
    }

    /// Projects UVs on all passed faces, automatically updating the sharedIndexesUV table as required (only associates
    /// vertices that share a seam).
    internal static func ProjectFacesAuto(mesh: ProBuilderMesh, faces: [Face], channel: Int) {
    }

    /// Projects UVs for each face using the closest normal on a box.
    public static func ProjectFacesBox(mesh: ProBuilderMesh, faces: [Face], channel: Int = 0) {
    }

    /// Finds the minimal U and V coordinate of a set of an array of UVs
    internal static func FindMinimalUV(uvs: [Vector2], indices: [Int]? = nil, xMin: Float = 0, yMin: Float = 0) -> Vector2 {
        Vector2()
    }

    /// Projects UVs for each face using the closest normal on a box and then place the lower left coordinate at the anchor position.
    public static func ProjectFacesBox(mesh: ProBuilderMesh, faces: [Face], lowerLeftAnchor: Vector2, channel: Int = 0) {
    }

    /// Projects UVs for each face using the closest normal on a sphere.
    public static func ProjectFacesSphere(pb: ProBuilderMesh, indexes: [Int], channel: Int = 0) {
    }

    /// Returns normalized UV values for a mesh uvs (0,0) - (1,1)
    public static func FitUVs(uvs: [Vector2]) -> [Vector2] {
        []
    }

    //MARK: - Stitch
    /// Provided two faces, this method will attempt to project @f2 and align its size, rotation, and position to match
    /// the shared edge on f1.  Returns true on success, false otherwise.
    public static func AutoStitch(mesh: ProBuilderMesh, f1: Face, f2: Face, channel: Int) -> Bool {
        false
    }

    /// move the UVs to where the edges passed meet
    static func AlignEdges(mesh: ProBuilderMesh, faceToMove: Face, edgeToAlignTo: Edge, edgeToBeAligned: Edge, channel: Int) -> Bool {
        false
    }
}
