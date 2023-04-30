//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IConstraintProvider {
    func GetConstraintCount() -> Int
    func GetParticleCount(at constraintIndex: Int) -> Int
    func GetParticle(at constraintIndex: Int, index: Int) -> Int
    mutating func WriteSortedConstraint(at constraintIndex: Int, sortedIndex: Int)
}
