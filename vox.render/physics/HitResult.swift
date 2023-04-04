//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Structure used to get information back from a raycast or a sweep.
public struct HitResult {
    /// The entity that was hit.
    public var entity: Entity?
    /// The distance from the ray's origin to the impact point.
    public var distance: Float = 0
    /// The impact point in world space where the ray hit the collider.
    public var point: Vector3 = .init()
    /// The normal of the surface the ray hit.
    public var normal: Vector3 = .init()

    public var collider: Collider?
    public var colliderShape: ColliderShape?

    public init() {}
}
