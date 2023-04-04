//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// How the handle gizmo is oriented with regards to the current element selection.
/// This overrides the Unity Pivot / Global setting when editing vertices, faces, or edges.
public enum HandleOrientation: UInt8 {
    /// The gizmo is aligned to identity in world space.
    case World = 0

    /// The gizmo is aligned relative to the active mesh transform. Also called coordinate or model space.
    case ActiveObject = 1

    /// The gizmo is aligned relative to the currently selected face. When editing vertices or edges, this falls back to <see cref="ActiveObject"/> alignment.
    case ActiveElement = 2
}
