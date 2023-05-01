//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Represents a group of related particles. ObiActor does not make
/// any assumptions about the relationship between these particles, except that they get allocated
/// and released together.
public class ObiActor: Script, IObiParticleCollection {
    public var particleCount: Int = 0

    public var activeParticleCount: Int = 0

    public var usesOrientedParticles: Bool = false

    public func GetParticleRuntimeIndex(at _: Int) -> Int {
        0
    }

    public func GetParticlePosition(at _: Int) -> Vector3 {
        Vector3()
    }

    public func GetParticleOrientation(at _: Int) -> Quaternion {
        Quaternion()
    }

    public func GetParticleAnisotropy(at _: Int, b1 _: inout Vector4, b2 _: inout Vector4, b3 _: inout Vector4) {}

    public func GetParticleMaxRadius(at _: Int) -> Float {
        0
    }

    public func GetParticleColor(at _: Int) -> Color {
        Color()
    }
}
