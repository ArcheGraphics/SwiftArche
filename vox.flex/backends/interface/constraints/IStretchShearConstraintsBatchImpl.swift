//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IStretchShearConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetStretchShearConstraints(particleIndices: [Int], orientationIndices: [Int],
                                    restLengths: [Float], restOrientations: [Quaternion],
                                    stiffnesses: [Vector3], lambdas: [Float], count: Int)
}
