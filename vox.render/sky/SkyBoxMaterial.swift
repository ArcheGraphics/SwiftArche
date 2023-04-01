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
                if newValue {
                    shader = ShaderFactory.skyboxHDR
                } else {
                    shader = ShaderFactory.skybox
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

    public init(_ name: String = "skybox mat") {
        super.init(shader: ShaderFactory.skybox, name)
    }
}
