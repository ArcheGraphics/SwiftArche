//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstRay: IDistanceFunction {
    public func Query(shapeIndex _: Int,
                      positions _: [float4],
                      orientations _: [quaternion],
                      radii _: [float4],
                      simplices _: [Int],
                      simplexIndex _: Int,
                      simplexStart _: Int,
                      simplexSize _: Int,
                      results _: inout [BurstQueryResult],
                      optimizationIterations _: Int,
                      optimizationTolerance _: Float) {}

    public func Evaluate(point _: float4, radii _: float4, orientation _: quaternion,
                         projectedPoint _: BurstLocalOptimization.SurfacePoint) {}

    public var shape: BurstQueryShape
    public var colliderToSolver: BurstAffineTransform
}
