//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for manipulating the transform of a mesh.
public enum MeshTransform {
    /// Set the pivot point for a mesh to either the center, or a corner point of the bounding box.
    /// - Parameters:
    ///   - mesh: The <see cref="ProBuilderMesh"/> to adjust vertices for a new pivot point.
    ///   - pivotLocation: The new pivot point is either the center of the mesh bounding box, or
    /// the bounds center - extents.
    internal static func SetPivot(mesh _: ProBuilderMesh, pivotLocation _: PivotLocation) {}

    /// Center the mesh pivot at the average of a set of vertices.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - indexes: The indexes of the positions to average to find the new pivot.
    public static func CenterPivot(mesh _: ProBuilderMesh, indexes _: [Int]) {}

    /// Set the pivot point of a mesh in world space. The Transform component position property is set to worldPosition, while the mesh geometry does not move.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - worldPosition: The new pivot position in world space.
    public static func SetPivot(mesh _: ProBuilderMesh, worldPosition _: Vector3) {}

    /// Scale vertices and set transform.localScale to Vector3.one.
    /// - Parameter mesh: The target mesh.
    public static func FreezeScaleTransform(mesh _: ProBuilderMesh) {}
}
