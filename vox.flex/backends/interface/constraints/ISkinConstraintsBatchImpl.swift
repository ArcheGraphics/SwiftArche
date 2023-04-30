//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ISkinConstraintsBatchImpl: IConstraintsBatchImpl {
    func SetSkinConstraints(particleIndices: [Int], skinPoints: [Vector4],
                            skinNormals: [Vector4], skinRadiiBackstop: [Float],
                            skinCompliance: [Float], lambdas: [Float], count: Int)
}
