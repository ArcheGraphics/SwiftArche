//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiBoxShapeTracker: ObiShapeTracker {
    public init(source: ObiCollider, collider: StaticCollider) {
        super.init(source: source, collider: collider)
    }

    override public func UpdateIfNeeded() -> Bool {
        false
    }
}
