//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct StructuralConstraint {
    public var batchIndex: IStructuralConstraintBatch
    public var constraintIndex: Int
    public var force: Float

    public var restLength: Float {
        get {
            0
        }

        set {}
    }

    public init(batchIndex: IStructuralConstraintBatch, constraintIndex: Int, force: Float) {
        self.batchIndex = batchIndex
        self.constraintIndex = constraintIndex
        self.force = force
    }
}
