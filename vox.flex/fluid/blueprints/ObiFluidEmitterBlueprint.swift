//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiFluidEmitterBlueprint: ObiEmitterBlueprintBase {
    // fluid parameters:
    public var smoothing: Float = 2
    /// viscosity of the fluid particles.
    public var viscosity: Float = 0.05
    /// surface tension of the fluid particles.
    public var surfaceTension: Float = 1

    // gas parameters:
    /// how dense is this material with respect to air?
    public var buoyancy: Float = -1.0
    /// amount of drag applied by the surrounding air to particles near the surface of the material.
    public var atmosphericDrag: Float = 0.0
    /// amount of pressure applied by the surrounding air particles.
    public var atmosphericPressure: Float = 0.0
    /// amount of vorticity confinement.
    public var vorticity: Float = 0.0

    public var diffusion: Float = 0.0
    /// values affected by diffusion.
    public var diffusionData = Vector4()

    public func GetSmoothingRadius(mode _: Oni.SolverParameters.Mode) -> Float {
        0
    }
}
