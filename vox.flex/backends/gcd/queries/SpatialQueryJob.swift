//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct SpatialQueryJob {
    // collider grid:
    public private(set) var grid: NativeMultilevelGrid<Int>

    // particle arrays:
    public private(set) var positions: [float4]
    public private(set) var orientations: [quaternion]
    public private(set) var radii: [float4]
    public private(set) var filters: [Int]

    // simplex arrays:
    public private(set) var simplices: [Int]
    public private(set) var simplexCounts: SimplexCounts

    // query arrays:
    public private(set) var shapes: [BurstQueryShape]
    public private(set) var transforms: [BurstAffineTransform]

    // output contacts queue:
    public var results: [BurstQueryResult]

    // auxiliar data:
    public private(set) var worldToSolver: BurstAffineTransform
    public private(set) var parameters: Oni.SolverParameters

    // execute for each query shape:
    public func Execute(i _: Int) {}

    private func CalculateShapeAABB(shape _: BurstQueryShape) -> BurstAabb {
        BurstAabb(min: float4(), max: float4())
    }

    private func Query(shape _: BurstQueryShape,
                       shapeToSolver _: BurstAffineTransform,
                       shapeIndex _: Int,
                       simplexIndex _: Int,
                       simplexStart _: Int,
                       simplexSize _: Int) {}
}

public struct CalculateQueryDistances {
    public private(set) var prevPositions: [float4]
    public private(set) var prevOrientations: [quaternion]
    public private(set) var radii: [float4]

    // simplex arrays:
    public private(set) var simplices: [Int]
    public private(set) var simplexCounts: SimplexCounts

    public var queryResults: [BurstQueryResult]

    public func Execute(i _: Int) {}
}
