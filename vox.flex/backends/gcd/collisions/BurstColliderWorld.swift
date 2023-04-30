//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

public class BurstColliderWorld: Script {
    struct MovingCollider {
        public var oldSpan: BurstCellSpan
        public var newSpan: BurstCellSpan
        public var entity: Int
    }
}
