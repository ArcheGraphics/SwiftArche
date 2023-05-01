//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Interface for classes that hold a collection of particles. Contains method to get common particle properties.
public protocol IObiParticleCollection {
    var particleCount: Int { get }
    var activeParticleCount: Int { get }
    var usesOrientedParticles: Bool { get }

    /// returns solver or blueprint index, depending on implementation./
    func GetParticleRuntimeIndex(at index: Int) -> Int
    func GetParticlePosition(at index: Int) -> Vector3
    func GetParticleOrientation(at index: Int) -> Quaternion
    func GetParticleAnisotropy(at index: Int, b1: inout Vector4, b2: inout Vector4, b3: inout Vector4)
    func GetParticleMaxRadius(at index: Int) -> Float
    func GetParticleColor(at index: Int) -> Color
}
