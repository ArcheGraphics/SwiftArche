//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol IShapeMatchingConstraintsUser {
    var shapeMatchingConstraintsEnabled: Bool {
        get
        set
    }

    var deformationResistance: Float {
        get
        set
    }

    var maxDeformation: Float {
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

    var plasticRecovery: Float {
        get
        set
    }
}

public class ObiShapeMatchingConstraintsData: ObiConstraints<ObiShapeMatchingConstraintsBatch> {
    override public func CreateBatch(source _: ObiShapeMatchingConstraintsBatch? = nil) -> ObiShapeMatchingConstraintsBatch
    {
        return ObiShapeMatchingConstraintsBatch()
    }
}
