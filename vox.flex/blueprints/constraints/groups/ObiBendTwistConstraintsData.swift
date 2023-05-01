//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IBendTwistConstraintsUser {
    var bendTwistConstraintsEnabled: Bool {
        get
        set
    }

    func GetBendTwistCompliance(batch: ObiBendTwistConstraintsBatch, constraintIndex: Int) -> Vector3
    func GetBendTwistPlasticity(batch: ObiBendTwistConstraintsBatch, constraintIndex: Int) -> Vector2
}

public class ObiBendTwistConstraintsData: ObiConstraints<ObiBendTwistConstraintsBatch> {
    override public func CreateBatch(source _: ObiBendTwistConstraintsBatch? = nil) -> ObiBendTwistConstraintsBatch
    {
        return ObiBendTwistConstraintsBatch()
    }
}
