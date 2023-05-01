//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiEmitterBlueprintBase: ObiActorBlueprint {
    public var capacity: UInt = 1000
    public var resolution: Float = 1
    /// rest density of the material.
    public var restDensity: Float = 1000

    /// Returns the diameter (2 * radius) of a single particle of this material.
    public func GetParticleSize(mode: Oni.SolverParameters.Mode) -> Float {
        return 1.0 / (10 * pow(resolution, 1.0 / (mode == Oni.SolverParameters.Mode.Mode3D ? 3.0 : 2.0)))
    }

    /// Returns the mass (in kilograms) of a single particle of this material.
    public func GetParticleMass(mode _: Oni.SolverParameters.Mode) -> Float {
        0
    }
}
