//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstChainConstraints: BurstConstraintsImpl<BurstChainConstraintsBatch> {
    public init(solver: BurstSolverImpl) {
        super.init(solver: solver, constraintType: Oni.ConstraintType.Chain)
    }

    override public func CreateConstraintsBatch() -> IConstraintsBatchImpl {
        let dataBatch = BurstChainConstraintsBatch(constraints: self)
        batches.append(dataBatch)
        return dataBatch
    }

    override public func RemoveBatch(batch: IConstraintsBatchImpl) {
        batches.removeAll { b in
            b === (batch as! BurstChainConstraintsBatch)
        }
        batch.Destroy()
    }
}
