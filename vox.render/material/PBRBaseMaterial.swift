//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class PBRBaseMaterial: BaseMaterial {
    private static let _occlusionIntensityProp = "u_occlusionIntensity"
    private static let _occlusionTextureCoordProp = "u_occlusionTextureCoord"
    private static let _occlusionTextureProp = "u_occlusionTexture"
    private static let _occlusionSamplerProp = "u_occlusionSampler"

    private static let _clearCoatProp = "u_clearCoat"
    private static let _clearCoatTextureProp = "u_clearCoatTexture"
    private static let _clearCoatSamplerProp = "u_clearCoatSampler"
    private static let _clearCoatRoughnessProp = "u_clearCoatRoughness"
    private static let _clearCoatRoughnessTextureProp = "u_clearCoatRoughnessTexture"
    private static let _clearCoatRoughnessSamplerProp = "u_clearCoatRoughnessSampler"
    private static let _clearCoatNormalTextureProp = "u_clearCoatNormalTexture"
    private static let _clearCoatNormalSamplerProp = "u_clearCoatNormalSampler"

    static let _metallicProp = "u_metallic"
    static let _roughnessProp = "u_roughness"
    static let _roughnessMetallicTextureProp = "u_roughnessMetallicTexture"
    static let _roughnessMetallicSamplerProp = "u_roughnessMetallicSampler"

    static var _specularProp = "u_specular"
    static var _glossinessProp = "u_glossiness"
    static var _specularGlossinessTextureProp = "u_specularGlossinessTexture"
    static var _specularGlossinessSamplerProp = "u_specularGlossinessSampler"

    /// Base color.
    @Serialized(default: Color(1, 1, 1, 1))
    public var baseColor: Color {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._baseColorProp, data: baseColor.toLinear())
        }
    }

    /// Base texture.
    public var baseTexture: MTLTexture? {
        didSet {
            if let baseTexture {
                if let srgbFormat = baseTexture.pixelFormat.toSRGB {
                    shaderData.setImageSampler(with: PBRBaseMaterial._baseTextureProp, PBRBaseMaterial._baseSamplerProp,
                                               texture: baseTexture.makeTextureView(pixelFormat: srgbFormat))
                } else {
                    shaderData.setImageSampler(with: PBRBaseMaterial._baseTextureProp, PBRBaseMaterial._baseSamplerProp, texture: baseTexture)
                }
                shaderData.enableMacro(HAS_BASE_TEXTURE.rawValue)
            } else {
                shaderData.setImageSampler(with: PBRBaseMaterial._baseTextureProp, PBRBaseMaterial._baseSamplerProp, texture: nil)
                shaderData.disableMacro(HAS_BASE_TEXTURE.rawValue)
            }
        }
    }

    public var baseSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._baseSamplerProp, sampler: baseSampler)
        }
    }

    /// Normal texture.
    public var normalTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRBaseMaterial._normalTextureProp,
                                       PBRBaseMaterial._normalSamplerProp, texture: normalTexture)
            if normalTexture != nil {
                shaderData.enableMacro(HAS_NORMAL_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_NORMAL_TEXTURE.rawValue)
            }
        }
    }

    public var normalSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._normalSamplerProp, sampler: normalSampler)
        }
    }

    /// Normal texture intensity.
    @Serialized(default: 1)
    public var normalTextureIntensity: Float {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._normalIntensityProp, data: normalTextureIntensity)
        }
    }

    /// Emissive color.
    @Serialized(default: Color(0, 0, 0))
    public var emissiveColor: Color {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._emissiveColorProp, data: emissiveColor.toLinear())
        }
    }

    /// Emissive texture.
    public var emissiveTexture: MTLTexture? {
        didSet {
            if let emissiveTexture {
                if let srgbFormat = emissiveTexture.pixelFormat.toSRGB {
                    shaderData.setImageSampler(with: PBRBaseMaterial._emissiveTextureProp, PBRBaseMaterial._emissiveSamplerProp,
                                               texture: emissiveTexture.makeTextureView(pixelFormat: srgbFormat))
                } else {
                    shaderData.setImageSampler(with: PBRBaseMaterial._emissiveTextureProp,
                                               PBRBaseMaterial._emissiveSamplerProp, texture: emissiveTexture)
                }
                shaderData.enableMacro(HAS_EMISSIVE_TEXTURE.rawValue)
            } else {
                shaderData.setImageSampler(with: PBRBaseMaterial._emissiveTextureProp,
                                           PBRBaseMaterial._emissiveSamplerProp, texture: nil)
                shaderData.disableMacro(HAS_EMISSIVE_TEXTURE.rawValue)
            }
        }
    }

    public var emissiveSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._emissiveSamplerProp, sampler: emissiveSampler)
        }
    }

    /// Occlusion texture.
    public var occlusionTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRBaseMaterial._occlusionTextureProp,
                                       PBRBaseMaterial._occlusionSamplerProp, texture: occlusionTexture)
            if occlusionTexture != nil {
                shaderData.enableMacro(HAS_OCCLUSION_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_OCCLUSION_TEXTURE.rawValue)
            }
        }
    }

    public var occlusionSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._occlusionSamplerProp, sampler: occlusionSampler)
        }
    }

    /// Occlusion texture intensity.
    @Serialized(default: 1)
    public var occlusionTextureIntensity: Float {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._occlusionIntensityProp, data: occlusionTextureIntensity)
        }
    }

    /// Occlusion texture uv coordinate.
    @Serialized(default: .UV0)
    public var occlusionTextureCoord: TextureCoordinate {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._occlusionTextureCoordProp, data: occlusionTextureCoord.rawValue)
        }
    }

    /// The clearCoat layer intensity, default 0.
    @Serialized(default: 0)
    public var clearCoat: Float {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._clearCoatProp, data: clearCoat)
            if clearCoat == 0 {
                shaderData.disableMacro(IS_CLEARCOAT.rawValue)
            } else {
                shaderData.enableMacro(IS_CLEARCOAT.rawValue)
            }
        }
    }

    /// The clearCoat layer intensity texture.
    public var clearCoatTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRBaseMaterial._clearCoatTextureProp,
                                       PBRBaseMaterial._clearCoatSamplerProp, texture: clearCoatTexture)
            if clearCoatTexture != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_TEXTURE.rawValue)
            }
        }
    }

    public var clearCoatSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._clearCoatSamplerProp, sampler: clearCoatSampler)
        }
    }

    /// The clearCoat layer roughness, default 0.
    @Serialized(default: 0)
    public var clearCoatRoughness: Float {
        didSet {
            shaderData.setData(with: PBRBaseMaterial._clearCoatRoughnessProp, data: clearCoatRoughness)
        }
    }

    /// The clearCoat layer roughness texture.
    public var clearCoatRoughnessTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRBaseMaterial._clearCoatRoughnessTextureProp,
                                       PBRBaseMaterial._clearCoatRoughnessSamplerProp, texture: clearCoatRoughnessTexture)
            if clearCoatRoughnessTexture != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_ROUGHNESS_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_ROUGHNESS_TEXTURE.rawValue)
            }
        }
    }

    public var clearCoatRoughnessSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._clearCoatRoughnessSamplerProp, sampler: clearCoatRoughnessSampler)
        }
    }

    /// The clearCoat normal map texture.
    public var clearCoatNormalTexture: MTLTexture? {
        didSet {
            shaderData.setImageSampler(with: PBRBaseMaterial._clearCoatNormalTextureProp,
                                       PBRBaseMaterial._clearCoatNormalSamplerProp, texture: clearCoatNormalTexture)
            if clearCoatNormalTexture != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_NORMAL_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_NORMAL_TEXTURE.rawValue)
            }
        }
    }

    public var clearCoatNormalSampler: MTLSamplerDescriptor? {
        didSet {
            shaderData.setSampler(with: PBRBaseMaterial._clearCoatNormalSamplerProp, sampler: clearCoatNormalSampler)
        }
    }

    public required init() {
        super.init()
        shader = ShaderFactory.pbr
        name = "pbr"
        shaderData.setData(with: PBRBaseMaterial._baseColorProp, data: baseColor)
        shaderData.setData(with: PBRBaseMaterial._normalIntensityProp, data: normalTextureIntensity)
        shaderData.setData(with: PBRBaseMaterial._emissiveColorProp, data: emissiveColor)
        shaderData.setData(with: PBRBaseMaterial._occlusionIntensityProp, data: occlusionTextureIntensity)
        shaderData.setData(with: PBRBaseMaterial._occlusionTextureCoordProp, data: occlusionTextureCoord.rawValue)
        shaderData.setData(with: PBRBaseMaterial._clearCoatProp, data: clearCoat)
        shaderData.setData(with: PBRBaseMaterial._clearCoatRoughnessProp, data: clearCoatRoughness)
    }

    override func createArgumentBuffer() {
        super.createArgumentBuffer()
        // can be simplify by shader framework, parse a json of reflection data
        var desc = MTLArgumentDescriptor()
        desc.index = 0
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._baseColorProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 1
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._emissiveColorProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 2
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._normalIntensityProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 3
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._occlusionIntensityProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 4
        desc.dataType = .int
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._occlusionTextureCoordProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 5
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 6
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatRoughnessProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 7
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._metallicProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 8
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._roughnessProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 9
        desc.dataType = .float4
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._specularProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 10
        desc.dataType = .float
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._glossinessProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 11
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._baseTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 12
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._baseSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 13
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._normalTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 14
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._normalSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 15
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._emissiveTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 16
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._emissiveSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 17
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._roughnessMetallicTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 18
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._roughnessMetallicSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 19
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._specularGlossinessTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 20
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._specularGlossinessSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 21
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._occlusionTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 22
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._occlusionSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 23
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 24
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 25
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatNormalTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 26
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatNormalSamplerProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 27
        desc.dataType = .texture
        desc.textureType = .type2D
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatRoughnessTextureProp, descriptor: desc)

        desc = MTLArgumentDescriptor()
        desc.index = 28
        desc.dataType = .sampler
        desc.access = .readOnly
        shaderData.registerArgumentDescriptor(with: PBRBaseMaterial._clearCoatRoughnessSamplerProp, descriptor: desc)
        shaderData.createArgumentBuffer(with: "u_pbrMaterial")

        shaderData.enableMacro(NEED_WORLDPOS.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
    }
}
