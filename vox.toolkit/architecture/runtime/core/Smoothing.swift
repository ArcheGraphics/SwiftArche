//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Utilities for working with smoothing groups. Smoothing groups are how ProBuilder defines hard and soft edges.
/// ProBuilder calculates vertex normals by first calculating the normal for every face, which in turn is applied to each
/// vertex that makes up the face. Afterwards, each vertex normal is averaged with coincident vertices belonging to the
/// same smoothing group.
public enum Smoothing {
    /// Faces with smoothingGroup = 0 are hard edges. Historically negative values were sometimes also written as hard edges.
    internal static let smoothingGroupNone = 0

    /// Smoothing groups 1-24 are smooth.
    internal static let smoothRangeMin = 1

    /// Smoothing groups 1-24 are smooth.
    internal static let smoothRangeMax = 24

    /// Smoothing groups 25-42 are hard. Note that this is obsolete, and generally hard faces should be marked smoothingGroupNone.
    internal static let hardRangeMin = 25

    /// Smoothing groups 25-42 are hard. Note that this is soon to be obsolete, and generally hard faces should be marked smoothingGroupNone.
    internal static let hardRangeMax = 42

    /// Get the first available unused smoothing group.
    /// - Parameter mesh: The target mesh.
    /// - Returns: An unused smoothing group.
    public static func GetUnusedSmoothingGroup(mesh _: ProBuilderMesh) -> Int {
        0
    }

    /// Get the first available smooth group after a specified index.
    static func GetNextUnusedSmoothingGroup(start _: Int, used _: Set<Int>) -> Int {
        0
    }

    /// Is the smooth group value considered smooth?
    /// - Parameter index: The smoothing group to test.
    /// - Returns: True if the smoothing group value is smoothed, false if not.
    public static func IsSmooth(at index: Int) -> Bool {
        index > smoothingGroupNone && (index < hardRangeMin || index > hardRangeMax)
    }

    /// Generate smoothing groups for a set of faces by comparing adjacent faces with normal differences less than angleThreshold (in degrees).
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: Faces to be considered for smoothing.
    ///   - angleThreshold: The maximum angle difference in degrees between adjacent face normals for the shared edge to be considered smooth.
    public static func ApplySmoothingGroups(mesh _: ProBuilderMesh, faces _: [Face], angleThreshold _: Float) {}

    internal static func ApplySmoothingGroups(mesh _: ProBuilderMesh, faces _: [Face], angleThreshold _: Float, normals _: [Vector3]) {}

    // Walk the perimiter of a wing looking for compatibly smooth connections. Returns true if any match was found, false if not.
    static func FindSoftEdgesRecursive(normals _: [Vector3], wing _: WingedEdge, angleThreshold _: Float, processed _: Set<Face>) -> Bool {
        false
    }

    static func IsSoftEdge(normals _: [Vector3], left _: EdgeLookup, right _: EdgeLookup, threshold _: Float) -> Bool {
        false
    }
}
