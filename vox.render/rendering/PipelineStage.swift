//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Pipeline stage.
public enum PipelineStage: String {
    /// Shadow caster stage.
    case ShadowCaster = "ShadowCaster"
    /// Forward shading stage.
    case Forward = "Forward"
    /// Deferrd shading stage.
    case Deferrd = "Deferrd"
}
