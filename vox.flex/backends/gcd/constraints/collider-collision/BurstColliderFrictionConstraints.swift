//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstColliderFrictionConstraints: BurstConstraintsImpl<BurstColliderFrictionConstraintsBatch>
{
    public init(solver: BurstSolverImpl) {
        super.init(solver: solver, constraintType: Oni.ConstraintType.Friction)
    }

    override public func CreateConstraintsBatch() -> IConstraintsBatchImpl {
        var dataBatch = BurstColliderFrictionConstraintsBatch(constraints: self)
        batches.append(dataBatch)
        return dataBatch
    }

    override public func RemoveBatch(batch: IConstraintsBatchImpl) {
        batches.removeAll { b in
            b === (batch as! BurstColliderFrictionConstraintsBatch)
        }
        batch.Destroy()
    }

    override public func GetConstraintCount() -> Int {
        return (solver as! BurstSolverImpl).colliderContacts.count
    }
}
