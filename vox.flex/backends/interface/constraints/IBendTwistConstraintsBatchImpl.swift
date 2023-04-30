//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IBendTwistConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetBendTwistConstraints(orientationIndices: [Int], restDarboux: [Quaternion],
                                 stiffnesses: [Vector3], plasticity: [Vector2], lambdas: [Float], count: Int)
}
