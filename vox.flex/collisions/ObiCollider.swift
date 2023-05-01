//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Add this component to any Collider that you want to be considered by Obi.
public class ObiCollider: ObiColliderBase {
    var m_SourceCollider: StaticCollider?

    private var m_DistanceField: ObiDistanceField?
}
