//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

/// Ambient light.
public class AmbientLight {
    private var _envMapLight = EnvMapLight(diffuse: vector_float3(0.212, 0.227, 0.259), mipMapLevel: 0,
                                           diffuseIntensity: 1.0, specularIntensity: 1.0)
    private static let _envMapProperty = "u_envMapLight"

    private var _diffuseSphericalHarmonics: SphericalHarmonics3?
    private var _shArray: [SIMD3<Float>] = [SIMD3<Float>](repeating: SIMD3<Float>(), count: 9)
    private static let _diffuseSHProperty = "u_env_sh"

    private var _specularTextureDecodeRGBM: Bool = false
    private var _specularTexture: MTLTexture?
    private static var _specularTextureProperty = "u_env_specularTexture"
    private static var _specularSamplerProperty = "u_env_specularSampler"

    private var _scenes: [Scene] = []
    private var _diffuseMode: DiffuseMode = .SolidColor

    /// Whether to decode from specularTexture with RGBM format.
    public var specularTextureDecodeRGBM: Bool {
        get {
            _specularTextureDecodeRGBM
        }
        set {
            _specularTextureDecodeRGBM = newValue
            for scene in _scenes {
                _setSpecularTextureDecodeRGBM(scene.shaderData)
            }
        }
    }


    /// Diffuse mode of ambient light.
    public var diffuseMode: DiffuseMode {
        get {
            _diffuseMode
        }
        set {
            _diffuseMode = newValue
            for scene in _scenes {
                _setDiffuseMode(scene.shaderData)
            }
        }
    }

    /// Diffuse reflection solid color.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SolidColor`.
    public var diffuseSolidColor: Vector3 {
        get {
            Vector3(_envMapLight.diffuse)
        }
        set {
            _envMapLight.diffuse = newValue.internalValue
        }
    }

    /// Diffuse reflection spherical harmonics 3.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SphericalHarmonics`.
    public var diffuseSphericalHarmonics: SphericalHarmonics3? {
        get {
            _diffuseSphericalHarmonics
        }
        set {
            _diffuseSphericalHarmonics = newValue
            if newValue != nil {
                _shArray = _preComputeSH(newValue!)
                for scene in _scenes {
                    scene.shaderData.setData(AmbientLight._diffuseSHProperty, _shArray)
                }
            }
        }
    }

    /// Diffuse reflection intensity.
    public var diffuseIntensity: Float {
        get {
            _envMapLight.diffuseIntensity
        }
        set {
            _envMapLight.diffuseIntensity = newValue
            for scene in _scenes {
                scene.shaderData.setData(AmbientLight._envMapProperty, _envMapLight)
            }
        }
    }

    /// Specular reflection texture.
    public var specularTexture: MTLTexture? {
        get {
            _specularTexture
        }
        set {
            _specularTexture = newValue
            for scene in _scenes {
                _setSpecularTexture(scene.shaderData)
            }
        }
    }

    /// Specular reflection intensity.
    public var specularIntensity: Float {
        get {
            _envMapLight.specularIntensity
        }
        set {
            _envMapLight.specularIntensity = newValue
            for scene in _scenes {
                scene.shaderData.setData(AmbientLight._envMapProperty, _envMapLight)
            }
        }
    }

    func _addToScene(_ scene: Scene) {
        _scenes.append(scene)

        let shaderData = scene.shaderData
        shaderData.setData(AmbientLight._envMapProperty, _envMapLight)
        shaderData.setData(AmbientLight._diffuseSHProperty, _shArray)

        _setDiffuseMode(shaderData)
        _setSpecularTextureDecodeRGBM(shaderData)
        _setSpecularTexture(shaderData)
    }


    func _removeFromScene(_ scene: Scene) {
        _scenes.removeAll { (v: Scene) in
            v === scene
        }
    }

    private func _setDiffuseMode(_ sceneShaderData: ShaderData) {
        if (_diffuseMode == DiffuseMode.SphericalHarmonics) {
            sceneShaderData.enableMacro(HAS_SH)
        } else {
            sceneShaderData.disableMacro(HAS_SH)
        }
    }

    private func _setSpecularTexture(_ sceneShaderData: ShaderData) {
        if (_specularTexture != nil) {
            sceneShaderData.setImageView(AmbientLight._specularTextureProperty, AmbientLight._specularSamplerProperty, _specularTexture)
            _envMapLight.mipMapLevel = Int32(_specularTexture!.mipmapLevelCount)
            sceneShaderData.setData(AmbientLight._envMapProperty, _envMapLight)
            sceneShaderData.enableMacro(HAS_SPECULAR_ENV)
        } else {
            sceneShaderData.disableMacro(HAS_SPECULAR_ENV)
        }
    }

    private func _setSpecularTextureDecodeRGBM(_ sceneShaderData: ShaderData) {
        if (_specularTextureDecodeRGBM) {
            sceneShaderData.enableMacro(DECODE_ENV_RGBM)
        } else {
            sceneShaderData.disableMacro(DECODE_ENV_RGBM)
        }
    }

    private func _preComputeSH(_ sh: SphericalHarmonics3) -> [SIMD3<Float>] {
        /**
         * Basis constants
         *
         * 0: 1/2 * Math.sqrt(1 / Math.PI)
         *
         * 1: -1/2 * Math.sqrt(3 / Math.PI)
         * 2: 1/2 * Math.sqrt(3 / Math.PI)
         * 3: -1/2 * Math.sqrt(3 / Math.PI)
         *
         * 4: 1/2 * Math.sqrt(15 / Math.PI)
         * 5: -1/2 * Math.sqrt(15 / Math.PI)
         * 6: 1/4 * Math.sqrt(5 / Math.PI)
         * 7: -1/2 * Math.sqrt(15 / Math.PI)
         * 8: 1/4 * Math.sqrt(15 / Math.PI)
         */

        /**
         * Convolution kernel
         *
         * 0: Math.PI
         * 1: (2 * Math.PI) / 3
         * 2: Math.PI / 4
         */

        let src = sh.coefficients

        var out = [SIMD3<Float>](repeating: SIMD3<Float>(), count: 9)
        // l0
        out[0] = [src[0] * 0.886227, src[1] * 0.886227, src[2] * 0.886227] // kernel0 * basis0 = 0.886227

        // l1
        out[1] = [src[3] * -1.023327, src[4] * -1.023327, src[5] * -1.023327] // kernel1 * basis1 = -1.023327
        out[2] = [src[6] * 1.023327, src[7] * 1.023327, src[8] * 1.023327] // kernel1 * basis2 = 1.023327
        out[3] = [src[9] * -1.023327, src[10] * -1.023327, src[11] * -1.023327] // kernel1 * basis3 = -1.023327

        // l2
        out[4] = [src[12] * 0.858086, src[13] * 0.858086, src[14] * 0.858086] // kernel2 * basis4 = 0.858086
        out[5] = [src[15] * -0.858086, src[16] * -0.858086, src[17] * -0.858086] // kernel2 * basis5 = -0.858086
        out[6] = [src[18] * 0.247708, src[19] * 0.247708, src[20] * 0.247708] // kernel2 * basis6 = 0.247708
        out[7] = [src[21] * -0.858086, src[22] * -0.858086, src[23] * -0.858086] // kernel2 * basis7 = -0.858086
        out[8] = [src[24] * 0.429042, src[25] * 0.429042, src[26] * 0.429042] // kernel2 * basis8 = 0.429042

        return out
    }
}
