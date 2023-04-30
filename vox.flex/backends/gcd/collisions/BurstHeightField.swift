//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstHeightField: IDistanceFunction, IBurstCollider {
    public var shape: BurstColliderShape
    public var colliderToSolver: BurstAffineTransform
    public var solverToWorld: BurstAffineTransform
    public var dt: Float
    public var collisionMargin: Float

    public var tri: BurstMath.CachedTri
    public var triNormal: float4

    public var header: HeightFieldHeader
    public var heightFieldSamples: [Float]

    public func Evaluate(point _: float4, radii _: float4, orientation _: quaternion,
                         projectedPoint _: BurstLocalOptimization.SurfacePoint) {}

    func Contacts(colliderIndex _: Int, rigidbodyIndex _: Int, rigidbodies _: [BurstRigidbody],
                  positions _: [float4], orientations _: [quaternion], velocities _: [float4],
                  radii _: [float4], simplices _: [Int], simplexBounds _: BurstAabb,
                  simplexIndex _: Int, simplexStart _: Int, simplexSize _: Int, contacts _: [BurstContact],
                  optimizationIterations _: Int, optimizationTolerance _: Float) {}
}
