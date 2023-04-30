//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstBendConstraints: BurstConstraintsImpl<BurstBendConstraintsBatch> {
    public init(solver: BurstSolverImpl) {
        super.init(solver: solver, constraintType: Oni.ConstraintType.Bending)
    }

    override public func CreateConstraintsBatch() -> IConstraintsBatchImpl {
        let dataBatch = BurstBendConstraintsBatch(constraints: self)
        batches.append(dataBatch)
        return dataBatch
    }

    override public func RemoveBatch(batch: IConstraintsBatchImpl) {
        batches.removeAll { b in
            b === (batch as! BurstBendConstraintsBatch)
        }

        batch.Destroy()
    }
}
