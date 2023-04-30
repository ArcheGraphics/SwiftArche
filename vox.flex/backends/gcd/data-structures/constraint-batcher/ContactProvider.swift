//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ContactProvider: IConstraintProvider {
    public var contacts: [BurstContact]
    public var sortedContacts: [BurstContact]
    public var simplices: [Int]
    public var simplexCounts: SimplexCounts

    public func GetConstraintCount() -> Int {
        return contacts.count
    }

    public func GetParticleCount(at constraintIndex: Int) -> Int {
        var simplexSizeA = 0
        var simplexSizeB = 0
        _ = simplexCounts.GetSimplexStartAndSize(at: contacts[constraintIndex].bodyA, size: &simplexSizeA)
        _ = simplexCounts.GetSimplexStartAndSize(at: contacts[constraintIndex].bodyB, size: &simplexSizeB)
        return simplexSizeA + simplexSizeB
    }

    public func GetParticle(at constraintIndex: Int, index: Int) -> Int {
        var simplexSizeA = 0
        var simplexSizeB = 0
        let simplexStartA = simplexCounts.GetSimplexStartAndSize(at: contacts[constraintIndex].bodyA, size: &simplexSizeA)
        let simplexStartB = simplexCounts.GetSimplexStartAndSize(at: contacts[constraintIndex].bodyB, size: &simplexSizeB)
        if index < simplexSizeA {
            return simplices[simplexStartA + index]
        } else {
            return simplices[simplexStartB + index - simplexSizeA]
        }
    }

    public mutating func WriteSortedConstraint(at constraintIndex: Int, sortedIndex: Int) {
        sortedContacts[sortedIndex] = contacts[constraintIndex]
    }
}
