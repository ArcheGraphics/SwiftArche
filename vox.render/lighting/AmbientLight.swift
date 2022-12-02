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

    private var _diffuseSphericalHarmonics: BufferView?
    private static let _diffuseSHProperty = "u_env_sh"

    private var _specularTextureDecodeRGBM: Bool = false
    private var _specularTexture: MTLTexture?
    private static var _specularTextureProperty = "u_env_specularTexture"
    private static var _specularSamplerProperty = "u_env_specularSampler"

    private var _scenes: [Scene] = []
    private var _diffuseMode: DiffuseMode = .SolidColor

    public init() {}

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
    public var diffuseSolidColor: Color {
        get {
            Color(_envMapLight.diffuse, 1.0)
        }
        set {
            _envMapLight.diffuse = newValue.toLinear().rgb
        }
    }

    /// Diffuse reflection spherical harmonics 3.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SphericalHarmonics`.
    public var diffuseSphericalHarmonics: BufferView? {
        get {
            _diffuseSphericalHarmonics
        }
        set {
            _diffuseSphericalHarmonics = newValue
            if newValue != nil {
                for scene in _scenes {
                    scene.shaderData.setData(AmbientLight._diffuseSHProperty, newValue!)
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
        if let _diffuseSphericalHarmonics = _diffuseSphericalHarmonics {
            shaderData.setData(AmbientLight._diffuseSHProperty, _diffuseSphericalHarmonics)
        }

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
            sceneShaderData.enableMacro(HAS_SH.rawValue)
        } else {
            sceneShaderData.disableMacro(HAS_SH.rawValue)
        }
    }

    private func _setSpecularTexture(_ sceneShaderData: ShaderData) {
        if (_specularTexture != nil) {
            sceneShaderData.setImageView(AmbientLight._specularTextureProperty, AmbientLight._specularSamplerProperty, _specularTexture)
            _envMapLight.mipMapLevel = Int32(_specularTexture!.mipmapLevelCount)
            sceneShaderData.setData(AmbientLight._envMapProperty, _envMapLight)
            sceneShaderData.enableMacro(HAS_SPECULAR_ENV.rawValue)
        } else {
            sceneShaderData.disableMacro(HAS_SPECULAR_ENV.rawValue)
        }
    }

    private func _setSpecularTextureDecodeRGBM(_ sceneShaderData: ShaderData) {
        if (_specularTextureDecodeRGBM) {
            sceneShaderData.enableMacro(DECODE_ENV_RGBM.rawValue)
        } else {
            sceneShaderData.disableMacro(DECODE_ENV_RGBM.rawValue)
        }
    }
}
