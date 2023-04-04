//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Snapping functions (didn't exist in UnityEngine prior to 2019.3)
class ProBuilderSnapping {
    static let k_MaxRaySnapDistance = Float.infinity

    internal static func IsCardinalDirection(_: Vector3) -> Bool {
        false
    }

    public static func Snap(val _: Float, snap _: Float) -> Float {
        0
    }

    public static func Snap(val _: Vector3, snap _: Vector3) -> Vector3 {
        Vector3()
    }

    /// Snap all vertices to an increment of @snapValue in world space.
    public static func SnapVertices<T: Sequence<Int>>(mesh _: ProBuilderMesh, indexes _: T, snap _: Vector3) {}

    internal static func GetSnappingMaskBasedOnNormalVector(_: Vector3) -> Vector3 {
        Vector3()
    }

    internal static func SnapValueOnRay(_: Ray, distance _: Float, snap _: Float, mask _: Vector3Mask) -> Vector3 {
        Vector3()
    }
}
