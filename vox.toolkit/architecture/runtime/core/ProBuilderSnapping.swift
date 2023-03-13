//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Snapping functions (didn't exist in UnityEngine prior to 2019.3)
class ProBuilderSnapping {
    static let k_MaxRaySnapDistance = Float.infinity

    internal static func IsCardinalDirection(_ direction: Vector3) -> Bool {
        false
    }

    public static func Snap(val: Float, snap: Float) -> Float {
        0
    }

    public static func Snap(val: Vector3, snap: Vector3) -> Vector3 {
        Vector3()
    }

    /// Snap all vertices to an increment of @snapValue in world space.
    public static func SnapVertices<T: Sequence<Int>>(mesh: ProBuilderMesh, indexes: T, snap: Vector3) {
    }

    internal static func GetSnappingMaskBasedOnNormalVector(_ normal: Vector3) -> Vector3 {
        Vector3()
    }


    internal static func SnapValueOnRay(_ ray: Ray, distance: Float, snap: Float, mask: Vector3Mask) -> Vector3 {
        Vector3()
    }
}
