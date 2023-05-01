//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IStretchShearConstraintsUser {
    var stretchShearConstraintsEnabled: Bool {
        get
        set
    }

    func GetStretchShearCompliance(batch: ObiStretchShearConstraintsBatch, constraintIndex: Int) -> Vector3
}

public class ObiStretchShearConstraintsData: ObiConstraints<ObiStretchShearConstraintsBatch> {
    override public func CreateBatch(source _: ObiStretchShearConstraintsBatch? = nil) -> ObiStretchShearConstraintsBatch
    {
        return ObiStretchShearConstraintsBatch()
    }
}
