//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Defines how the bounding volumes intersects or contain one another.
public enum ContainmentType {
    /// Indicates that there is no overlap between two bounding volumes.
    case Disjoint
    /// Indicates that one bounding volume completely contains another volume.
    case Contains
    /// Indicates that bounding volumes partially overlap one another.
    case Intersects
}
