//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ITetherConstraintsUser {
    var tetherConstraintsEnabled: Bool {
        get
        set
    }

    var tetherCompliance: Bool {
        get
        set
    }

    var tetherScale: Bool {
        get
        set
    }
}

public class ObiTetherConstraintsData: ObiConstraints<ObiTetherConstraintsBatch> {
    override public func CreateBatch(source _: ObiTetherConstraintsBatch? = nil) -> ObiTetherConstraintsBatch
    {
        return ObiTetherConstraintsBatch()
    }
}
