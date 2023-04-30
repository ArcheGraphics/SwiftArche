//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct FluidInteractionProvider: IConstraintProvider {
    public var interactions: [FluidInteraction]
    public var sortedInteractions: [FluidInteraction]

    public func GetConstraintCount() -> Int {
        return interactions.count
    }

    public func GetParticleCount(at _: Int) -> Int {
        return 2
    }

    public func GetParticle(at constraintIndex: Int, index: Int) -> Int {
        return interactions[constraintIndex].GetParticle(at: index)
    }

    public mutating func WriteSortedConstraint(at constraintIndex: Int, sortedIndex: Int) {
        sortedInteractions[sortedIndex] = interactions[constraintIndex]
    }
}
