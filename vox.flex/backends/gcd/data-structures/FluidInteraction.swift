//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct FluidInteraction: IConstraint {
    public var gradient: float4
    public var avgKernel: Float
    public var avgGradient: Float
    public var particleA: Int
    public var particleB: Int

    public func GetParticleCount() -> Int { return 2 }
    public func GetParticle(at index: Int) -> Int { return index == 0 ? particleA : particleB }
}
