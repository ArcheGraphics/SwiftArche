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

    public static func Optimize<T: IDistanceFunction>(function _: T,
                                                      positions _: [float4],
                                                      orientations _: [quaternion],
                                                      radii _: [float4],
                                                      simplices _: [Int],
                                                      simplexStart _: Int,
                                                      simplexSize _: Int,
                                                      convexBary _: float4,
                                                      convexPoint _: inout float4,
                                                      maxIterations _: Int = 16,
                                                      tolerance _: Float = 0.004) -> SurfacePoint
    {
        SurfacePoint(bary: float4(), point: float4(), normal: float4())
    }

    /// Frank-Wolfe convex optimization algorithm.
    /// Returns closest point to a simplex in a signed distance function.
    private static func FrankWolfe<T: IDistanceFunction>(function _: T,
                                                         simplexStart _: Int,
                                                         simplexSize _: Int,
                                                         positions _: [float4],
                                                         orientations _: [quaternion],
                                                         radii _: [float4],
                                                         simplices _: [Int],
                                                         convexPoint _: float4,
                                                         convexThickness _: float4,
                                                         convexOrientation _: quaternion,
                                                         convexBary _: float4,
                                                         pointInFunction _: SurfacePoint,
                                                         maxIterations _: Int,
                                                         tolerance _: Float) {}

    private static func GoldenSearch<T: IDistanceFunction>(function _: T,
                                                           simplexStart _: Int,
                                                           simplexSize _: Int,
                                                           positions _: [float4],
                                                           orientations _: [quaternion],
                                                           radii _: [float4],
                                                           simplices _: [Int],
                                                           convexPoint _: float4,
                                                           convexThickness _: float4,
                                                           convexOrientation _: quaternion,
                                                           convexBary _: float4,
                                                           pointInFunction _: SurfacePoint,
                                                           maxIterations _: Int,
                                                           tolerance _: Float) {}
}

public protocol IDistanceFunction {
    func Evaluate(point: float4, radii: float4, orientation: quaternion, projectedPoint: BurstLocalOptimization.SurfacePoint)
}
