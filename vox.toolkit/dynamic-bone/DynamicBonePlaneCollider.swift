//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class DynamicBonePlaneCollider: DynamicBoneColliderBase {
    var m_Plane = Plane()

    override public func prepare() {
        var normal = Vector3.up
        switch m_Direction {
        case Direction.X:
            normal = entity.transform.worldRight
        case Direction.Y:
            normal = entity.transform.worldUp
        case Direction.Z:
            normal = entity.transform.worldForward
        }

        let p = Vector3.transformCoordinate(v: m_Center, m: entity.transform.worldMatrix)
        m_Plane.setNormalAndPosition(normal, p)
    }

    override public func collide(particlePosition: inout Vector3, particleRadius _: Float) -> Bool {
        let d = CollisionUtil.distancePlaneAndPoint(plane: m_Plane, point: particlePosition)

        if m_Bound == Bound.Outside {
            if d < 0 {
                particlePosition -= m_Plane.normal * d
                return true
            }
        } else {
            if d > 0 {
                particlePosition -= m_Plane.normal * d
                return true
            }
        }
        return false
    }
}
