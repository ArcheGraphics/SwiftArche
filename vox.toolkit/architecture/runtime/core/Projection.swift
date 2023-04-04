//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for projecting 3d points to 2d space.
public enum Projection {
    /// Project a collection of 3d positions to a 2d plane. The direction from which the vertices are projected
    /// is calculated using <see cref="FindBestPlane"/>.
    /// - Parameters:
    ///   - positions: A collection of positions to project based on a direction.
    ///   - indexes: indexes
    /// - Returns: The positions array projected into 2d coordinates.
    public static func PlanarProject(positions _: [Vector3], indexes _: [Int]? = nil) -> [Vector2] {
        []
    }

    /// Project a collection of 3d positions to a 2d plane.
    /// - Parameters:
    ///   - positions: A collection of positions to project based on a direction.
    ///   - indexes: A collection of indices to project. The returned array will match the length of indices.
    ///   - direction: The direction from which vertex positions are projected into 2d space.
    /// - Returns: The positions array projected into 2d coordinates.
    public static func PlanarProject(positions _: [Vector3], indexes _: [Int], direction _: Vector3) -> [Vector2] {
        []
    }

    internal static func PlanarProject(positions _: [Vector3], indexes _: [Int], direction _: Vector3, results _: [Vector2]) {}

    internal static func PlanarProject(mesh _: ProBuilderMesh, textureGroup _: Int, unwrapSettings _: AutoUnwrapSettings) {}

    internal static func PlanarProject(mesh _: ProBuilderMesh, face _: Face, projection _: Vector3 = Vector3()) {}

    internal static func SphericalProject(vertices _: [Vector3], indexes _: [Int]? = nil) -> [Vector2] {
        []
    }

    /// Returns a new set of points wound as a contour counter-clockwise.
    internal static func Sort(verts _: [Vector2], method _: SortMethod = SortMethod.CounterClockwise) -> [Vector2] {
        []
    }

    internal static func GetTangentToAxis(_: ProjectionAxis) -> Vector3 {
        Vector3()
    }

    /// Given a ProjectionAxis, return  the appropriate Vector3 conversion.
    internal static func ProjectionAxisToVector(axis _: ProjectionAxis) -> Vector3 {
        Vector3()
    }

    /// Returns a projection axis based on which axis is the largest
    internal static func VectorToProjectionAxis(direction _: Vector3) -> ProjectionAxis {
        ProjectionAxis.X
    }

    /// Find a plane that best fits a set of 3d points.
    /// - Remark:
    /// http://www.ilikebigbits.com/blog/2015/3/2/plane-from-points
    /// - Parameters:
    ///   - points: The points to find a plane for. Order does not matter.
    ///   - indexes: If provided, only the vertices referenced by the indexes array will be considered.
    /// - Returns: A plane that best matches the layout of the points array.
    public static func FindBestPlane(points _: [Vector3], indexes _: [Int]? = nil) -> Plane {
        Plane()
    }

    /// Find a plane that best fits a set of faces within a texture group.
    /// - Parameters:
    ///   - mesh: mesh
    ///   - textureGroup: textureGroup
    /// - Returns: A plane that best matches the layout of the points array.
    internal static func FindBestPlane(mesh _: ProBuilderMesh, textureGroup _: Int) -> Plane {
        Plane()
    }
}
