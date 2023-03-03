//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

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
    internal static func Extrude(points: [BezierPoint],
                                 radius: Float = 0.5,
                                 columns: Int = 32,
                                 rows: Int = 16,
                                 closeLoop: Bool = false,
                                 smooth: Bool = true) -> ProBuilderMesh? {
            nil
    }

    // Update a pb_Object with new geometry from a bezier spline.
    internal static func Extrude(bezierPoints: [BezierPoint],
                                 radius: Float,
                                 columns: Int,
                                 rows: Int,
                                 closeLoop: Bool,
                                 smooth: Bool,
                                 target: inout ProBuilderMesh) {

    }

    // Extrapolate a bezier curve to it's control points and segments between.
    internal static func GetControlPoints(bezierPoints: [BezierPoint], subdivisionsPerSegment: Int,
                                          closeLoop: Bool, rotations: [Quaternion]) -> [Vector3] {
        []
    }


    // Set mesh geometry by extruding along a set of points.
    internal static func Extrude(points: [Vector3],
                                 radius: Float,
                                 radiusRows: Int,
                                 closeLoop: Bool,
                                 smooth: Bool,
                                 target: inout ProBuilderMesh,
                                 pointRotations: [Quaternion]? = nil) {

    }

    static func GetRingRotation(points: [Vector3], i: Float, closeLoop: Bool, secant: inout Float) -> Quaternion {
        Quaternion()
    }

    static func VertexRing(orientation: Quaternion, offset: Vector3, radius: Float, segments: Int) -> [Vector3] {
        []
    }

}
