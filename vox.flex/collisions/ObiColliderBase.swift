//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

/// Implements common functionality for ObiCollider and ObiCollider2D.
public class ObiColliderBase: Script {
    private var thickness: Float = 0

    private var material: ObiCollisionMaterial?

    private var filter: Int = 0
}
