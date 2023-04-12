//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class DynamicBoneColliderBase: Script {
    public enum Direction {
        case X, Y, Z
    }

    /// The axis of the capsule's height.
    public var m_Direction: Direction = .Y

    /// The center of the sphere or capsule, in the object's local space.
    public var m_Center: Vector3 = .zero

    public enum Bound {
        case Outside
        case Inside
    }

    /// Constrain bones to outside bound or inside bound.
    public var m_Bound: Bound = .Outside

    public var PrepareFrame: Int = 0

    public func prepare() {}

    public func collide(particlePosition _: inout Vector3, particleRadius _: Float) -> Bool {
        return false
    }
}
