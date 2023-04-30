//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public enum BurstLocalOptimization {
    /// point in the surface of a signed distance field.
    public struct SurfacePoint {
        public var bary: float4
        public var point: float4
        public var normal: float4
    }

    private static func GetInterpolatedSimplexData(simplexStart _: Int,
                                                   simplexSize _: Int,
                                                   simplices _: [Int],
                                                   positions _: [float4],
                                                   orientations _: [quaternion],
                                                   radii _: [float4],
                                                   convexBary _: float4,
                                                   convexPoint _: inout float4,
                                                   convexRadii _: inout float4,
                                                   convexOrientation _: inout quaternion) {}
}

public protocol IDistanceFunction {
    func Evaluate(point: float4, radii: float4, orientation: quaternion, projectedPoint: BurstLocalOptimization.SurfacePoint)
}
