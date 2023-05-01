//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct BuildSimplexAabbs {
    public private(set) var radii: [float4]
    public private(set) var fluidRadii: [Float]
    public private(set) var positions: [float4]
    public private(set) var velocities: [float4]

    // simplex arrays:
    public private(set) var simplices: [Int]
    public private(set) var simplexCounts: SimplexCounts

    public private(set) var particleMaterialIndices: [Int]
    public private(set) var collisionMaterials: [CollisionMaterial]
    public private(set) var collisionMargin: Float
    public private(set) var continuousCollisionDetection: Float
    public private(set) var dt: Float

    public var simplexBounds: [BurstAabb]

    public func Execute(index _: Int) {}
}
