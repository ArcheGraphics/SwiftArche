//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class SkyBoxMaterial: Material {
    private var _textureCubeMap: MTLTexture!

    /// Texture cube map of the sky box material.
    public var textureCubeMap: MTLTexture {
        get {
            _textureCubeMap
        }
        set {
            _textureCubeMap = newValue
            shaderData.setImageView("u_cubeTexture", "u_cubeSampler", _textureCubeMap)
        }
    }

    public init(_ engine: Engine, _ name: String = "") {
        super.init(engine.device, name)
        shader.append(ShaderPass(engine.library(), "vertex_skybox", "fragment_skybox"))
    }
}
