//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IDistanceConstraintsUser {
    var distanceConstraintsEnabled: Bool {
        get
        set
    }

    var stretchingScale: Float {
        get
        set
    }

    var stretchCompliance: Float {
        get
        set
    }

    var maxCompression: Float {
        get
        set
    }
}

public class ObiDistanceConstraintsData: ObiConstraints<ObiDistanceConstraintsBatch> {
    override public func CreateBatch(source _: ObiDistanceConstraintsBatch? = nil) -> ObiDistanceConstraintsBatch
    {
        return ObiDistanceConstraintsBatch()
    }
}
