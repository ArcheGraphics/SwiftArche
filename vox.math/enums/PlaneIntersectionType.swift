//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Defines the intersection between a plane and a bounding volume.
public enum PlaneIntersectionType {
    /// There is no intersection, the bounding volume is in the back of the plane.
    case Back
    /// There is no intersection, the bounding volume is in the front of the plane.
    case Front
    /// The plane is intersected.
    case Intersecting
}
