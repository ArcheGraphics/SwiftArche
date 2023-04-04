//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public enum PivotPoint {
    /// Transforms are applied from the center point of the selection bounding box.
    /// Corresponds with <see cref="UnityEditor.PivotMode.Center"/>.
    case Center
    /// Transforms are applied from the origin of each selection group.
    case IndividualOrigins
    /// Transforms are applied from the active selection center.
    case ActiveElement
}
