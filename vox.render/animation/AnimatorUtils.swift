//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

internal class AnimatorUtils {
    static func scaleWeight(_ s: Vector3, _ w: Float) -> Vector3 {
        let sX = s.x
        let sY = s.y
        let sZ = s.z
        return Vector3(
                sX > 0 ? pow(abs(sX), w) : -pow(abs(sX), w),
                sY > 0 ? pow(abs(sY), w) : -pow(abs(sY), w),
                sZ > 0 ? pow(abs(sZ), w) : -pow(abs(sZ), w)
        )
    }

    static func scaleBlend(_ sa: Vector3, _ sb: Vector3, _ w: Float) -> Vector3 {
        let saw = AnimatorUtils.scaleWeight(sa, 1.0 - w)
        let sbw = AnimatorUtils.scaleWeight(sb, w)
        let sng = w > 0.5 ? sb : sa
        return Vector3(sng.x > 0 ? abs(saw.x * sbw.x) : -abs(saw.x * sbw.x),
                sng.y > 0 ? abs(saw.y * sbw.y) : -abs(saw.y * sbw.y),
                sng.z > 0 ? abs(saw.z * sbw.z) : -abs(saw.z * sbw.z))
    }

    static func quaternionWeight(_ s: Quaternion, _ w: Float) -> Quaternion {
        Quaternion(s.x * w, s.y * w, s.z * w, s.w)
    }
}
