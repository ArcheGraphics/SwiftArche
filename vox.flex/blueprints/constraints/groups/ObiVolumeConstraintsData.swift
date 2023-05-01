//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IVolumeConstraintsUser {
    var volumeConstraintsEnabled: Bool {
        get
        set
    }

    var compressionCompliance: Float {
        get
        set
    }

    var pressure: Float {
        get
        set
    }
}

public class ObiVolumeConstraintsData: ObiConstraints<ObiVolumeConstraintsBatch> {
    override public func CreateBatch(source _: ObiVolumeConstraintsBatch? = nil) -> ObiVolumeConstraintsBatch
    {
        return ObiVolumeConstraintsBatch()
    }
}
