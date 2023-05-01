//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IBendConstraintsUser {
    var bendConstraintsEnabled: Bool {
        get
        set
    }

    var bendCompliance: Float {
        get
        set
    }

    var maxBending: Float {
        get
        set
    }

    var plasticYield: Float {
        get
        set
    }

    var plasticCreep: Float {
        get
        set
    }
}

public class ObiBendConstraintsData: ObiConstraints<ObiBendConstraintsBatch> {
    override public func CreateBatch(source _: ObiBendConstraintsBatch? = nil) -> ObiBendConstraintsBatch
    {
        return ObiBendConstraintsBatch()
    }
}
