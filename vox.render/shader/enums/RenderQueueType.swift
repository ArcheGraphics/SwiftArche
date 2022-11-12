//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Render queue type.
public enum RenderQueueType {
    /// Opaque queue.
    case Opaque
    /// Opaque queue, alpha cutoff.
    case AlphaTest
    /// Transparent queue, rendering from back to front to ensure correct rendering of transparent objects.
    case Transparent
}
