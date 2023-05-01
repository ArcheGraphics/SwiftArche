//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IAerodynamicConstraintsUser {
    var aerodynamicsEnabled: Bool {
        get
        set
    }

    var drag: Float {
        get
        set
    }

    var lift: Float {
        get
        set
    }
}

public class ObiAerodynamicConstraintsData: ObiConstraints<ObiAerodynamicConstraintsBatch> {
    override public func CreateBatch(source _: ObiAerodynamicConstraintsBatch? = nil) -> ObiAerodynamicConstraintsBatch
    {
        return ObiAerodynamicConstraintsBatch()
    }
}
