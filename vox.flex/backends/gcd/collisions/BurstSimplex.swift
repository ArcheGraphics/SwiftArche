//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstSimplex: IDistanceFunction {
    public var positions: [float4]
    public var radii: [float4]
    public var simplices: [Int]

    public var simplexStart: Int
    public var simplexSize: Int

    public func CacheData() {}

    public func Evaluate(point _: float4, radii _: float4, orientation _: quaternion,
                         projectedPoint _: BurstLocalOptimization.SurfacePoint) {}
}
