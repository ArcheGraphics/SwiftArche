//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum ShaderTagKey: String {
    case pipelineStage
    case spriteDisableBatching
}

public enum ShaderProperty: Equatable {
    case Int(Int)
    case Bool(Bool)
    case String(String)
}

/// Pipeline stage.
public enum PipelineStage {
    /// Shadow caster stage.
    public static let ShadowCaster: ShaderProperty = .String("ShadowCaster")
    /// Forward shading stage.
    public static let Forward: ShaderProperty = .String("Forward")
    /// Deferrd shading stage.
    public static let Deferrd: ShaderProperty = .String("Deferrd")
}
