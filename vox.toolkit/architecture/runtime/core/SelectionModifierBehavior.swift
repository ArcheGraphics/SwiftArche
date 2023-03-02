//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// When drag selecting mesh elements, this defines how the Shift key will modify the selection.
public enum SelectionModifierBehavior {
    /// Always add to the selection.
    case Add
    /// Always subtract from the selection.
    case Subtract
    /// Invert the selected faces (default).
    case Difference
}
