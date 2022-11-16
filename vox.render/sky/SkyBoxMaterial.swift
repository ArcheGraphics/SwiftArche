//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class SkyBoxMaterial: Material {
    private var _textureDecodeRGBM: Bool = false
    private var _RGBMDecodeFactor: Float = 5.0
    private var _textureCubeMap: MTLTexture!

    /// Whether to decode from texture with RGBM format.
    var textureDecodeRGBM: Bool {
        get {
            _textureDecodeRGBM
        }
        set {
            _textureDecodeRGBM = newValue
            shaderData.setData("u_textureDecodeRGBM", _textureDecodeRGBM)
        }
    }

    /// RGBM decode factor, default 5.0.
    var RGBMDecodeFactor: Float {
        get {
            _RGBMDecodeFactor
        }
        set {
            _RGBMDecodeFactor = newValue
            shaderData.setData("u_RGBMDecodeFactor", _RGBMDecodeFactor)
        }
    }

    /// Texture cube map of the sky box material.
    var textureCubeMap: MTLTexture {
        get {
            _textureCubeMap
        }
        set {
            _textureCubeMap = newValue
            shaderData.setImageView("u_cube", "u_cubeSampler", _textureCubeMap)
        }
    }

    public init(_ engine: Engine, _ name: String = "") {
        super.init(engine.device, name)

        let shaderPass = ShaderPass(engine.library, "vertex_skybox", "fragment_skybox")
        shaderPass.renderState!.rasterState.cullMode = MTLCullMode.none
        shaderPass.renderState!.depthState.compareFunction = MTLCompareFunction.lessEqual
        shader.append(shaderPass)

        shaderData.enableMacro(NEED_WORLDPOS)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setData("u_textureDecodeRGBM", _textureDecodeRGBM)
        shaderData.setData("u_RGBMDecodeFactor", _RGBMDecodeFactor)
    }
}