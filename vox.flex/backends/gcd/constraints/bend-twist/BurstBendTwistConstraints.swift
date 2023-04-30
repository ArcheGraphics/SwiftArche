//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstBendTwistConstraints: BurstConstraintsImpl<BurstBendTwistConstraintsBatch> {
    public init(solver: BurstSolverImpl) {
        super.init(solver: solver, constraintType: Oni.ConstraintType.BendTwist)
    }

    override public func CreateConstraintsBatch() -> IConstraintsBatchImpl {
        let dataBatch = BurstBendTwistConstraintsBatch(constraints: self)
        batches.append(dataBatch)
        return dataBatch
    }

    override public func RemoveBatch(batch: IConstraintsBatchImpl) {
        batches.removeAll { b in
            b === (batch as! BurstBendTwistConstraintsBatch)
        }
        batch.Destroy()
    }
}
