//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

/// Ambient light.
public class AmbientLight: Serializable {
    private static let _diffuseColorProperty = "u_env_diffuse"
    private static let _diffuseIntensityProperty = "u_env_diffuseIntensity"
    private static let _specularIntensityProperty = "u_env_specularIntensity"
    private static let _mipmapProperty = "u_env_mipmap"

    private static let _diffuseSHProperty = "u_env_sh"

    private static var _specularTextureProperty = "u_env_specularTexture"
    private static var _specularSamplerProperty = "u_env_specularSampler"
    private var _sampler = MTLSamplerDescriptor()

    private var _scenes: [Scene] = []

    public required init() {
        _sampler.mipFilter = .linear
        _sampler.minFilter = .linear
        _sampler.magFilter = .linear
        _sampler.lodMinClamp = -1000
        _sampler.lodMaxClamp = 10000
        _sampler.rAddressMode = .repeat
        _sampler.sAddressMode = .clampToEdge
        _sampler.tAddressMode = .clampToEdge
        _sampler.supportArgumentBuffers = true
    }

    /// Diffuse mode of ambient light.
    public var diffuseMode: DiffuseMode = .SolidColor {
        didSet {
            for scene in _scenes {
                _setDiffuseMode(scene.shaderData)
            }
        }
    }

    /// Diffuse reflection solid color.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SolidColor`.
    public var diffuseSolidColor: Color = .init(0.212, 0.227, 0.259) {
        didSet {
            for scene in _scenes {
                scene.shaderData.setData(with: AmbientLight._diffuseColorProperty, data: diffuseSolidColor.toLinear())
            }
        }
    }

    /// Diffuse reflection spherical harmonics 3.
    /// - Remark: Effective when diffuse reflection mode is `DiffuseMode.SphericalHarmonics`.
    public var diffuseSphericalHarmonics: BufferView? {
        didSet {
            if let diffuseSphericalHarmonics {
                for scene in _scenes {
                    scene.shaderData.setData(with: AmbientLight._diffuseSHProperty, buffer: diffuseSphericalHarmonics.buffer)
                }
            }
        }
    }

    /// Diffuse reflection intensity.
    public var diffuseIntensity: Float = 1 {
        didSet {
            for scene in _scenes {
                scene.shaderData.setData(with: AmbientLight._diffuseIntensityProperty, data: diffuseIntensity)
            }
        }
    }

    /// Specular reflection texture.
    public var specularTexture: MTLTexture? {
        didSet {
            for scene in _scenes {
                _setSpecularTexture(scene.shaderData)
            }
        }
    }

    /// Specular reflection intensity.
    public var specularIntensity: Float = 1 {
        didSet {
            for scene in _scenes {
                scene.shaderData.setData(with: AmbientLight._specularIntensityProperty, data: specularIntensity)
            }
        }
    }

    func _addToScene(_ scene: Scene) {
        _scenes.append(scene)

        let shaderData = scene.shaderData
        var desc = MTLArgumentDescriptor()
        desc.index = 0
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._diffuseColorProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 1
        desc.dataType = .int
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._mipmapProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 2
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._diffuseIntensityProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 3
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._specularIntensityProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 4
        desc.dataType = .pointer
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._diffuseSHProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 5
        desc.dataType = .texture
        desc.textureType = .typeCube
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._specularTextureProperty, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 6
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: AmbientLight._specularSamplerProperty, descriptor: desc)
        shaderData.createArgumentBuffer(with: "u_envMapLight")

        if let diffuseSphericalHarmonics {
            shaderData.setData(with: AmbientLight._diffuseSHProperty, buffer: diffuseSphericalHarmonics.buffer)
        }
        shaderData.setData(with: AmbientLight._diffuseColorProperty, data: diffuseSolidColor.toLinear())
        shaderData.setData(with: AmbientLight._diffuseIntensityProperty, data: diffuseIntensity)
        shaderData.setData(with: AmbientLight._specularIntensityProperty, data: specularIntensity)
        _setDiffuseMode(shaderData)
        _setSpecularTexture(shaderData)
    }

    func _removeFromScene(_ scene: Scene) {
        _scenes.removeAll { (v: Scene) in
            v === scene
        }
    }

    private func _setDiffuseMode(_ sceneShaderData: ShaderData) {
        if diffuseMode == DiffuseMode.SphericalHarmonics {
            sceneShaderData.enableMacro(HAS_SH.rawValue)
        } else {
            sceneShaderData.disableMacro(HAS_SH.rawValue)
        }
    }

    private func _setSpecularTexture(_ sceneShaderData: ShaderData) {
        if let specularTexture {
            sceneShaderData.setImageView(with: AmbientLight._specularTextureProperty, texture: specularTexture)
            sceneShaderData.setSampler(with: AmbientLight._specularSamplerProperty, sampler: _sampler)
            sceneShaderData.setData(with: AmbientLight._mipmapProperty, data: Int32(specularTexture.mipmapLevelCount))
            sceneShaderData.enableMacro(HAS_SPECULAR_ENV.rawValue)
        } else {
            sceneShaderData.disableMacro(HAS_SPECULAR_ENV.rawValue)
        }
    }
}
