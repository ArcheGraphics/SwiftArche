//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct ParticleToBoundsJob {
    public private(set) var activeParticles: [Int]
    public private(set) var positions: [float4]
    public private(set) var radii: [float4]

    public var bounds: [BurstAabb]

    public func Execute(i _: Int) {}
}

struct BoundsReductionJob {
    // the length of bounds must be a multiple of size.
    public var bounds: [BurstAabb]
    public private(set) var stride: Int
    public private(set) var size: Int

    public func Execute(first _: Int) {}
}
