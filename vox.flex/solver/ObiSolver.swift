//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// ObiSolver simulates particles and constraints, provided by a list of ObiActor. Particles belonging to different solvers won't interact with each other in any way.
public final class ObiSolver: Script {
    public enum BackendType {
        case Burst
    }
}
