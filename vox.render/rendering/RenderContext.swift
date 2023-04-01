//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Rendering context.
struct RenderContext {
    var replacementShader: Shader?
    var replacementTag: String?
    var pipelineStageTagValue: ShaderProperty = PipelineStage.Forward
}
