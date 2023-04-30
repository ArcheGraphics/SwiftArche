//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ApplyCollisionConstraintsBatchJob {
    public private(set) var contacts: [BurstContact]

    public private(set) var simplices: [Int]
    public private(set) var simplexCounts: SimplexCounts

    public var positions: [float4]
    public var deltas: [float4]
    public var counts: [Int]

    public var orientations: [quaternion]
    public var orientationDeltas: [quaternion]
    public var orientationCounts: [Int]

    public private(set) var constraintParameters: Oni.ConstraintParameters

    public func Execute() {}
}
