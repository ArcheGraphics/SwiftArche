//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IChainConstraintsUser {
    var chainConstraintsEnabled: Bool {
        get
        set
    }

    var tightness: Float {
        get
        set
    }
}

public class ObiChainConstraintsData: ObiConstraints<ObiChainConstraintsBatch> {
    override public func CreateBatch(source _: ObiChainConstraintsBatch? = nil) -> ObiChainConstraintsBatch
    {
        return ObiChainConstraintsBatch()
    }
}
