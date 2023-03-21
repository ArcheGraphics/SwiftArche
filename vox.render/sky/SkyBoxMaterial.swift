//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

public class SkyBoxMaterial: Material {
    private var _textureCubeMap: MTLTexture!
    private var _equirectangular: Bool = false

    /// Whether to decode from texture with equirectangular HDR format.
    public var equirectangular: Bool {
        get {
            _equirectangular
        }
        set {
            if newValue != _equirectangular {
                _equirectangular = newValue
                shader = []
                if newValue {
                    shader.append(ShaderPass(Engine.library(), "vertex_skybox", "fragment_skyboxHDR"))
                } else {
                    shader.append(ShaderPass(Engine.library(), "vertex_skybox", "fragment_skybox"))
                }
            }
        }
    }
    
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

    public override init(_ name: String = "skybox mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library(), "vertex_skybox", "fragment_skybox"))
    }
}
