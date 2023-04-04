//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class Spline {
    /// Create a new pb_Object by extruding along a bezier spline.
    /// - Parameters:
    ///   - points: The points making up the bezier spline.
    ///   - radius: The radius of the extruded mesh tube.
    ///   - columns: How many columns per segment to create when extruding the mesh.
    ///   - rows: How many rows the extruded mesh will be composed of.
    ///   - closeLoop: Should the mesh join at the ends or remain unconnected.
    ///   - smooth: Are the mesh edges smoothed or hard.
    /// - Returns: The resulting pb_Object.
    internal static func Extrude(points _: [BezierPoint],
                                 radius _: Float = 0.5,
                                 columns _: Int = 32,
                                 rows _: Int = 16,
                                 closeLoop _: Bool = false,
                                 smooth _: Bool = true) -> ProBuilderMesh?
    {
        nil
    }

    // Update a pb_Object with new geometry from a bezier spline.
    internal static func Extrude(bezierPoints _: [BezierPoint],
                                 radius _: Float,
                                 columns _: Int,
                                 rows _: Int,
                                 closeLoop _: Bool,
                                 smooth _: Bool,
                                 target _: inout ProBuilderMesh) {}

    // Extrapolate a bezier curve to it's control points and segments between.
    internal static func GetControlPoints(bezierPoints _: [BezierPoint], subdivisionsPerSegment _: Int,
                                          closeLoop _: Bool, rotations _: [Quaternion]) -> [Vector3]
    {
        []
    }

    // Set mesh geometry by extruding along a set of points.
    internal static func Extrude(points _: [Vector3],
                                 radius _: Float,
                                 radiusRows _: Int,
                                 closeLoop _: Bool,
                                 smooth _: Bool,
                                 target _: inout ProBuilderMesh,
                                 pointRotations _: [Quaternion]? = nil) {}

    static func GetRingRotation(points _: [Vector3], i _: Float, closeLoop _: Bool, secant _: inout Float) -> Quaternion {
        Quaternion()
    }

    static func VertexRing(orientation _: Quaternion, offset _: Vector3, radius _: Float, segments _: Int) -> [Vector3] {
        []
    }
}
