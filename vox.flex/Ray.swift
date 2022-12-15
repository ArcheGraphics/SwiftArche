//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

///
/// Class for 3-D ray.
///
public struct Ray3F {
    public var origin: Vector3F
    public var direction: Vector3F

    /// Constructs an empty ray that points (1, 0, 0) from (0, 0, 0).
    public init() {
        origin = Vector3F.zero
        direction = Vector3F(1, 0, 0)
    }

    /// Constructs a ray with given origin and riection.
    public init(newOrigin: Vector3F, newDirection: Vector3F) {
        origin = newOrigin
        direction = normalize(newDirection)
    }

    /// Copy constructor.
    public init(other: Ray3F) {
        origin = other.origin
        direction = other.direction
    }

    public func pointAt(_ t: Float) -> Vector3F {
        origin + t * direction
    }
}
