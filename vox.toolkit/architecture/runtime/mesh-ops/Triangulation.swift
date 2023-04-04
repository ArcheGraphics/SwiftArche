//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// <summary>
/// Wrapper around Triangle.NET triangulation methods. https://github.com/zon/triangle
/// </summary>
class Triangulation {
    /// Given a set of points this method will format the points into a boundary contour and triangulate, returning
    /// a set of indexes that corresponds to the original ordering.
    public static func SortAndTriangulate(points _: [Vector2], indexes _: inout [Int], convex _: Bool = false) -> Bool {
        false
    }

    /// Attempts to triangulate a set of vertices. If unordered is specified as false vertices will not be re-ordered before triangulation.
    public static func TriangulateVertices(_: [Vertex], triangles _: inout [Int],
                                           unordered _: Bool = true, convex _: Bool = false) -> Bool
    {
        false
    }

    /// Attempts to triangulate an ordered set of vertices. Optionally with a set of hole polygons.
    /// - Parameters:
    ///   - vertices: Ordered set of vertices
    ///   - triangles: Resulting set of indices. Indices outside the vertices array are hole vertices.
    ///   When creating a mesh, add all the hole vertices to the vertices array so that the indices are valid.
    ///   - holes: Jagged array containing sets of vertices that make up holes in the polygon.
    public static func TriangulateVertices(_: [Vector3], triangles _: inout [Int],
                                           holes _: [[Vector3]]? = nil) -> Bool
    {
        false
    }

    public static func TriangulateVertices(_: [Vector3], triangles _: inout [Int],
                                           unordered _: Bool = true, convex _: Bool = false) -> Bool
    {
        false
    }

    /// Given a set of points ordered counter-clockwise along a contour, return triangle indexes.
    /// - Parameters:
    ///   - points: points
    ///   - indexes: indexes
    ///   - convex: convex
    /// - Returns: Triangulation may optionally be set to convex, which will result in some a convex shape.
    public static func Triangulate(points _: [Vector2], indexes _: inout [Int], convex _: Bool = false) -> Bool {
        false
    }

    /// Given a set of points ordered counter-clockwise along a contour and a set of holes, return triangle indexes.
    /// - Parameters:
    ///   - points: points
    ///   - holes: holes
    ///   - indexes: Indices outside of the points list index into holes when layed out linearly.
    /// {vertices 0,1,2...vertices.length-1, holes 0 values, hole 1 values etc.}
    public static func Triangulate(points _: [Vector2], holes _: [[Vector2]], indexes _: inout [Int]) -> Bool {
        false
    }
}
