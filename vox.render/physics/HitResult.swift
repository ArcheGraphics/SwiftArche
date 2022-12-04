//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Structure used to get information back from a raycast or a sweep.
public struct HitResult {
    /// The entity that was hit.
    public var entity: Entity? = nil
    /// The distance from the ray's origin to the impact point.
    public var distance: Float = 0
    /// The impact point in world space where the ray hit the collider.
    public var point: Vector3 = Vector3()
    /// The normal of the surface the ray hit.
    public var normal: Vector3 = Vector3()

    public init() {
    }
}