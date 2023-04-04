//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class SkyBoxMaterial: Material {
    /// Whether to decode from texture with equirectangular HDR format.
    public var equirectangular: Bool = false {
        didSet {
            if equirectangular {
                shader = ShaderFactory.skyboxHDR
            } else {
                shader = ShaderFactory.skybox
            }
        }
    }

    /// Texture cube map of the sky box material.
    public var textureCubeMap: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: "u_cubeTexture", "u_cubeSampler", texture: textureCubeMap)
        }
    }

    public required init() {
        super.init()
        shader = ShaderFactory.skybox
        name = "skybox mat"
    }
}
