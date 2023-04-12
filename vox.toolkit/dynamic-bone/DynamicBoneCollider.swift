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

    override public func prepare() {
        let worldMatrix = entity.transform.worldMatrix
        let scale = abs(entity.transform.lossyWorldScale.x)
        let halfHeight = m_Height * 0.5

        if m_Radius2 <= 0 || abs(m_Radius - m_Radius2) < 0.01 {
            m_ScaledRadius = m_Radius * scale

            let h = halfHeight - m_Radius
            if h <= 0 {
                m_C0 = Vector3.transformCoordinate(v: m_Center, m: worldMatrix)

                if m_Bound == Bound.Outside {
                    m_CollideType = 0
                } else {
                    m_CollideType = 1
                }
            } else {
                var c0 = m_Center
                var c1 = m_Center

                switch m_Direction {
                case Direction.X:
                    c0.x += h
                    c1.x -= h
                case Direction.Y:
                    c0.y += h
                    c1.y -= h
                case Direction.Z:
                    c0.z += h
                    c1.z -= h
                }

                m_C0 = Vector3.transformCoordinate(v: c0, m: worldMatrix)
                m_C1 = Vector3.transformCoordinate(v: c1, m: worldMatrix)
                m_C01Distance = (m_C1 - m_C0).length()

                if m_Bound == Bound.Outside {
                    m_CollideType = 2
                } else {
                    m_CollideType = 3
                }
            }
        } else {
            let r = max(m_Radius, m_Radius2)
            if halfHeight - r <= 0 {
                m_ScaledRadius = r * scale
                m_C0 = Vector3.transformCoordinate(v: m_Center, m: worldMatrix)

                if m_Bound == Bound.Outside {
                    m_CollideType = 0
                } else {
                    m_CollideType = 1
                }
            } else {
                m_ScaledRadius = m_Radius * scale
                m_ScaledRadius2 = m_Radius2 * scale

                let h0 = halfHeight - m_Radius
                let h1 = halfHeight - m_Radius2
                var c0 = m_Center
                var c1 = m_Center

                switch m_Direction {
                case Direction.X:
                    c0.x += h0
                    c1.x -= h1
                case Direction.Y:
                    c0.y += h0
                    c1.y -= h1
                case Direction.Z:
                    c0.z += h0
                    c1.z -= h1
                }

                m_C0 = Vector3.transformCoordinate(v: c0, m: worldMatrix)
                m_C1 = Vector3.transformCoordinate(v: c1, m: worldMatrix)
                m_C01Distance = (m_C1 - m_C0).length()

                if m_Bound == Bound.Outside {
                    m_CollideType = 4
                } else {
                    m_CollideType = 5
                }
            }
        }
    }

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

    static func outsideSphere(particlePosition: inout Vector3, particleRadius: Float,
                              sphereCenter: Vector3, sphereRadius: Float) -> Bool
    {
        let r = sphereRadius + particleRadius
        let r2 = r * r
        let d = particlePosition - sphereCenter
        let dlen2 = d.lengthSquared()

        // if is inside sphere, project onto sphere surface
        if dlen2 > 0 && dlen2 < r2 {
            let dlen = sqrt(dlen2)
            particlePosition = sphereCenter + d * (r / dlen)
            return true
        }
        return false
    }

    static func insideSphere(particlePosition: inout Vector3, particleRadius: Float,
                             sphereCenter: Vector3, sphereRadius: Float) -> Bool
    {
        let r = sphereRadius - particleRadius
        let r2 = r * r
        let d = particlePosition - sphereCenter
        let dlen2 = d.lengthSquared()

        // if is outside sphere, project onto sphere surface
        if dlen2 > r2 {
            let dlen = sqrt(dlen2)
            particlePosition = sphereCenter + d * (r / dlen)
            return true
        }
        return false
    }

    static func outsideCapsule(particlePosition: inout Vector3, particleRadius: Float,
                               capsuleP0: Vector3, capsuleP1: Vector3, capsuleRadius: Float, dirlen: Float) -> Bool
    {
        let r = capsuleRadius + particleRadius
        let r2 = r * r
        let dir = capsuleP1 - capsuleP0
        var d = particlePosition - capsuleP0
        let t = Vector3.dot(left: d, right: dir)

        if t <= 0 {
            // check sphere1
            let dlen2 = d.lengthSquared()
            if dlen2 > 0 && dlen2 < r2 {
                let dlen = sqrt(dlen2)
                particlePosition = capsuleP0 + d * (r / dlen)
                return true
            }
        } else {
            let dirlen2 = dirlen * dirlen
            if t >= dirlen2 {
                // check sphere2
                d = particlePosition - capsuleP1
                let dlen2 = d.lengthSquared()
                if dlen2 > 0 && dlen2 < r2 {
                    let dlen = sqrt(dlen2)
                    particlePosition = capsuleP1 + d * (r / dlen)
                    return true
                }
            } else {
                // check cylinder
                let q = d - dir * (t / dirlen2)
                let qlen2 = q.lengthSquared()
                if qlen2 > 0 && qlen2 < r2 {
                    let qlen = sqrt(qlen2)
                    particlePosition += q * ((r - qlen) / qlen)
                    return true
                }
            }
        }
        return false
    }

    static func insideCapsule(particlePosition: inout Vector3, particleRadius: Float,
                              capsuleP0: Vector3, capsuleP1: Vector3, capsuleRadius: Float, dirlen: Float) -> Bool
    {
        let r = capsuleRadius - particleRadius
        let r2 = r * r
        let dir = capsuleP1 - capsuleP0
        var d = particlePosition - capsuleP0
        let t = Vector3.dot(left: d, right: dir)

        if t <= 0 {
            // check sphere1
            let dlen2 = d.lengthSquared()
            if dlen2 > r2 {
                let dlen = sqrt(dlen2)
                particlePosition = capsuleP0 + d * (r / dlen)
                return true
            }
        } else {
            let dirlen2 = dirlen * dirlen
            if t >= dirlen2 {
                // check sphere2
                d = particlePosition - capsuleP1
                let dlen2 = d.lengthSquared()
                if dlen2 > r2 {
                    let dlen = sqrt(dlen2)
                    particlePosition = capsuleP1 + d * (r / dlen)
                    return true
                }
            } else {
                // check cylinder
                let q = d - dir * (t / dirlen2)
                let qlen2 = q.lengthSquared()
                if qlen2 > r2 {
                    let qlen = sqrt(qlen2)
                    particlePosition += q * ((r - qlen) / qlen)
                    return true
                }
            }
        }
        return false
    }

    static func outsideCapsule2(particlePosition: inout Vector3, particleRadius: Float,
                                capsuleP0: Vector3, capsuleP1: Vector3,
                                capsuleRadius0: Float, capsuleRadius1: Float, dirlen: Float) -> Bool
    {
        let dir = capsuleP1 - capsuleP0
        var d = particlePosition - capsuleP0
        let t = Vector3.dot(left: d, right: dir)

        if t <= 0 {
            // check sphere1
            let r = capsuleRadius0 + particleRadius
            let r2 = r * r
            let dlen2 = d.lengthSquared()
            if dlen2 > 0 && dlen2 < r2 {
                let dlen = sqrt(dlen2)
                particlePosition = capsuleP0 + d * (r / dlen)
                return true
            }
        } else {
            let dirlen2 = dirlen * dirlen
            if t >= dirlen2 {
                // check sphere2
                let r = capsuleRadius1 + particleRadius
                let r2 = r * r
                d = particlePosition - capsuleP1
                let dlen2 = d.lengthSquared()
                if dlen2 > 0 && dlen2 < r2 {
                    let dlen = sqrt(dlen2)
                    particlePosition = capsuleP1 + d * (r / dlen)
                    return true
                }
            } else {
                // check cylinder
                let q = d - dir * (t / dirlen2)
                let qlen2 = q.lengthSquared()

                let klen = Vector3.dot(left: d, right: dir / dirlen)
                let r = MathUtil.lerp(a: capsuleRadius0, b: capsuleRadius1, t: klen / dirlen) + particleRadius
                let r2 = r * r

                if qlen2 > 0 && qlen2 < r2 {
                    let qlen = sqrt(qlen2)
                    particlePosition += q * ((r - qlen) / qlen)
                    return true
                }
            }
        }
        return false
    }

    static func insideCapsule2(particlePosition: inout Vector3, particleRadius: Float,
                               capsuleP0: Vector3, capsuleP1: Vector3,
                               capsuleRadius0: Float, capsuleRadius1: Float, dirlen: Float) -> Bool
    {
        let dir = capsuleP1 - capsuleP0
        var d = particlePosition - capsuleP0
        let t = Vector3.dot(left: d, right: dir)

        if t <= 0 {
            // check sphere1
            let r = capsuleRadius0 - particleRadius
            let r2 = r * r
            let dlen2 = d.lengthSquared()
            if dlen2 > r2 {
                let dlen = sqrt(dlen2)
                particlePosition = capsuleP0 + d * (r / dlen)
                return true
            }
        } else {
            let dirlen2 = dirlen * dirlen
            if t >= dirlen2 {
                // check sphere2
                let r = capsuleRadius1 - particleRadius
                let r2 = r * r
                d = particlePosition - capsuleP1
                let dlen2 = d.lengthSquared()
                if dlen2 > r2 {
                    let dlen = sqrt(dlen2)
                    particlePosition = capsuleP1 + d * (r / dlen)
                    return true
                }
            } else {
                // check cylinder
                let q = d - dir * (t / dirlen2)
                let qlen2 = q.lengthSquared()

                let klen = Vector3.dot(left: d, right: dir / dirlen)
                let r = MathUtil.lerp(a: capsuleRadius0, b: capsuleRadius1, t: klen / dirlen) - particleRadius
                let r2 = r * r

                if qlen2 > r2 {
                    let qlen = sqrt(qlen2)
                    particlePosition += q * ((r - qlen) / qlen)
                    return true
                }
            }
        }
        return false
    }
}
