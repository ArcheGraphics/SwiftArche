//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// shader factory
public enum ShaderFactory {
    /// physical-based shading
    public static var pbr: Shader {
        let shadowCaster = ShaderPass(Engine.library(), "vertex_shadowmap", nil,
                                      tags: [ShaderTagKey.pipelineStage.rawValue: PipelineStage.ShadowCaster])
        return Shader.create(shaderPasses: [ShaderPass(Engine.library(), "vertex_pbr", "fragment_pbr"), shadowCaster])
    }

    /// unlit shading
    public static var unlit: Shader {
        let shadowCaster = ShaderPass(Engine.library(), "vertex_shadowmap", nil,
                                      tags: [ShaderTagKey.pipelineStage.rawValue: PipelineStage.ShadowCaster])
        return Shader.create(shaderPasses: [ShaderPass(Engine.library(), "vertex_unlit", "fragment_unlit"), shadowCaster])
    }

    /// skybox
    public static var skybox: Shader {
        Shader.create(in: Engine.library(), vertexSource: "vertex_skybox", fragmentSource: "fragment_skybox")
    }

    /// skybox with hdr
    public static var skyboxHDR: Shader {
        Shader.create(in: Engine.library(), vertexSource: "vertex_skybox", fragmentSource: "fragment_skyboxHDR")
    }

    /// backgroun texture
    public static var background: Shader {
        Shader.create(in: Engine.library(), vertexSource: "vertex_background", fragmentSource: "fragment_background")
    }
}
