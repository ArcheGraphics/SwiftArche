//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Sub shader.
public struct SubShader {
    public private(set) var passes: [ShaderPass]
    public private(set) var tagsMap: [String: ShaderProperty]

    /// Create a sub shader.
    init(name _: String, passes: [ShaderPass], tags: [String: ShaderProperty] = [:]) {
        self.passes = passes
        tagsMap = tags
    }
}
