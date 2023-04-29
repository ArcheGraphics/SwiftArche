//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct QueryResult {
    /// Barycentric coords of nearest point in simplex
    public var simplexBary: Vector4
    /// Nearest point in query shape
    public var queryPoint: Vector4
    /// Closest direction between simplex and query shape.
    public var normal: Vector4
    /// Distance between simplex and query shape.
    public var distance: Float
    /// Index of the simplex in the solver.
    public var simplexIndex: Int
    /// Index of the query that spawned this result.
    public var queryIndex: Int
}
