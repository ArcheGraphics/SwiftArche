//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class DynamicBoneCollider: DynamicBoneColliderBase {
    /// The radius of the sphere or capsule.
    public var m_Radius: Float = 0.5

    /// The height of the capsule.
    public var m_Height: Float = 0

    /// The other radius of the capsule.
    public var m_Radius2: Float = 0

    // prepare data
    var m_ScaledRadius: Float = 0
    var m_ScaledRadius2: Float = 0
    var m_C0: Vector3 = .init()
    var m_C1: Vector3 = .init()
    var m_C01Distance: Float = 0
    var m_CollideType: Int = 0

    override public func prepare() {}

    override public func collide(particlePosition: inout Vector3, particleRadius: Float) -> Bool {
        switch m_CollideType {
        case 0:
            return DynamicBoneCollider.outsideSphere(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                     sphereCenter: m_C0, sphereRadius: m_ScaledRadius)
        case 1:
            return DynamicBoneCollider.insideSphere(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                    sphereCenter: m_C0, sphereRadius: m_ScaledRadius)
        case 2:
            return DynamicBoneCollider.outsideCapsule(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                      capsuleP0: m_C0, capsuleP1: m_C1,
                                                      capsuleRadius: m_ScaledRadius, dirlen: m_C01Distance)
        case 3:
            return DynamicBoneCollider.insideCapsule(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                     capsuleP0: m_C0, capsuleP1: m_C1,
                                                     capsuleRadius: m_ScaledRadius, dirlen: m_C01Distance)
        case 4:
            return DynamicBoneCollider.outsideCapsule2(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                       capsuleP0: m_C0, capsuleP1: m_C1,
                                                       capsuleRadius0: m_ScaledRadius, capsuleRadius1: m_ScaledRadius2, dirlen: m_C01Distance)
        case 5:
            return DynamicBoneCollider.insideCapsule2(particlePosition: &particlePosition, particleRadius: particleRadius,
                                                      capsuleP0: m_C0, capsuleP1: m_C1,
                                                      capsuleRadius0: m_ScaledRadius, capsuleRadius1: m_ScaledRadius2, dirlen: m_C01Distance)
        default:
            return false
        }
    }

    static func outsideSphere(particlePosition _: inout Vector3, particleRadius _: Float,
                              sphereCenter _: Vector3, sphereRadius _: Float) -> Bool
    {
        false
    }

    static func insideSphere(particlePosition _: inout Vector3, particleRadius _: Float,
                             sphereCenter _: Vector3, sphereRadius _: Float) -> Bool
    {
        false
    }

    static func outsideCapsule(particlePosition _: inout Vector3, particleRadius _: Float,
                               capsuleP0 _: Vector3, capsuleP1 _: Vector3, capsuleRadius _: Float, dirlen _: Float) -> Bool
    {
        false
    }

    static func insideCapsule(particlePosition _: inout Vector3, particleRadius _: Float,
                              capsuleP0 _: Vector3, capsuleP1 _: Vector3, capsuleRadius _: Float, dirlen _: Float) -> Bool
    {
        false
    }

    static func outsideCapsule2(particlePosition _: inout Vector3, particleRadius _: Float,
                                capsuleP0 _: Vector3, capsuleP1 _: Vector3,
                                capsuleRadius0 _: Float, capsuleRadius1 _: Float, dirlen _: Float) -> Bool
    {
        false
    }

    static func insideCapsule2(particlePosition _: inout Vector3, particleRadius _: Float,
                               capsuleP0 _: Vector3, capsuleP1 _: Vector3,
                               capsuleRadius0 _: Float, capsuleRadius1 _: Float, dirlen _: Float) -> Bool
    {
        false
    }
}
