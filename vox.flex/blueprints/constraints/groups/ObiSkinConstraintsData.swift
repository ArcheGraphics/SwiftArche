//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ISkinConstraintsUser {
    var skinConstraintsEnabled: Bool {
        get
        set
    }

    func GetSkinRadiiBackstop(batch: ObiSkinConstraintsBatch, constraintIndex: Int) -> Vector3
    func GetSkinCompliance(batch: ObiSkinConstraintsBatch, constraintIndex: Int) -> Float
}

public class ObiSkinConstraintsData: ObiConstraints<ObiSkinConstraintsBatch> {
    override public func CreateBatch(source _: ObiSkinConstraintsBatch? = nil) -> ObiSkinConstraintsBatch
    {
        return ObiSkinConstraintsBatch()
    }
}
