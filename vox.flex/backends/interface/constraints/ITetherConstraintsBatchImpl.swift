//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ITetherConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetTetherConstraints(particleIndices: [Int], maxLengthScale: [Vector2],
                              stiffnesses: [Float], lambdas: [Float], count: Int)
}
