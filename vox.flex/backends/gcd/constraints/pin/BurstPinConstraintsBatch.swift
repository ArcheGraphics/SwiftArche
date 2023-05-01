//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstPinConstraintsBatch: BurstConstraintsBatchImpl, IPinConstraintsBatchImpl {
    private var colliderIndices: [Int] = []
    private var offsets: [float4] = []
    private var restDarbouxVectors: [quaternion] = []
    private var stiffnesses: [float2] = []

    public init(constraints: BurstPinConstraints) {
        super.init()
        m_Constraints = constraints
        m_ConstraintType = Oni.ConstraintType.Pin
    }

    public func SetPinConstraints(particleIndices _: [Int], colliderIndices _: [Int],
                                  offsets _: [Vector4], restDarbouxVectors _: [Quaternion],
                                  stiffnesses _: [Float], lambdas _: [Float], count _: Int) {}
}
