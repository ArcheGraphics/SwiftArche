//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class PBRBaseMaterial: BaseMaterial {
    struct PBRBaseData {
        var baseColor: Color = Color(1, 1, 1, 1)

        var emissiveColor: Vector3 = Vector3(0, 0, 0)
        var normalTextureIntensity: Float = 1

        var occlusionTextureIntensity: Float = 1
        var occlusionTextureCoord: TextureCoordinate = .UV0
        var clearCoat: Float = 0
        var clearCoatRoughness: Float = 0

        var tilingOffset: Vector4 = Vector4(1, 1, 0, 0)
    }

    private var _pbrBaseData = PBRBaseData()
    private static let _pbrBaseProp = "u_pbrBase"

    private var _baseTexture: MTLTexture?
    private var _normalTexture: MTLTexture?
    private var _emissiveTexture: MTLTexture?
    private var _tilingOffset = Vector4(1, 1, 0, 0)

    private var _occlusionTexture: MTLTexture?
    private static let _occlusionTextureProp = "u_occlusionTexture"
    private static let _occlusionSamplerProp = "u_occlusionSampler"

    private var _clearCoatTexture: MTLTexture?
    private static let _clearCoatTextureProp = "u_clearCoatTexture"
    private static let _clearCoatSamplerProp = "u_clearCoatSampler"

    private var _clearCoatRoughnessTexture: MTLTexture?
    private static let _clearCoatRoughnessTextureProp = "u_clearCoatRoughnessTexture"
    private static let _clearCoatRoughnessSamplerProp = "u_clearCoatRoughnessSampler"

    private var _clearCoatNormalTexture: MTLTexture?
    private static let _clearCoatNormalTextureProp = "u_clearCoatNormalTexture"
    private static let _clearCoatNormalSamplerProp = "u_clearCoatNormalSampler"

    /// Base color.
    public var baseColor: Color {
        get {
            _pbrBaseData.baseColor
        }

        set {
            _pbrBaseData.baseColor = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// Base texture.
    public var baseTexture: MTLTexture? {
        get {
            _baseTexture
        }
        set {
            _baseTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._baseTextureProp, PBRBaseMaterial._baseSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_BASE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_BASE_TEXTURE)
            }
        }
    }

    public func setBaseSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._baseSamplerProp, value)
    }

    /// Normal texture.
    public var normalTexture: MTLTexture? {
        get {
            _normalTexture
        }
        set {
            _normalTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._normalTextureProp, PBRBaseMaterial._normalTextureProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_NORMAL_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_NORMAL_TEXTURE)
            }
        }
    }

    public func setNormalSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._normalSamplerProp, value)
    }

    /// Normal texture intensity.
    public var normalTextureIntensity: Float {
        get {
            _pbrBaseData.normalTextureIntensity
        }

        set {
            _pbrBaseData.normalTextureIntensity = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// Emissive color.
    public var emissiveColor: Vector3 {
        get {
            _pbrBaseData.emissiveColor
        }

        set {
            _pbrBaseData.emissiveColor = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// Emissive texture.
    public var emissiveTexture: MTLTexture? {
        get {
            _emissiveTexture
        }
        set {
            _emissiveTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._emissiveTextureProp, PBRBaseMaterial._emissiveSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_EMISSIVE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_EMISSIVE_TEXTURE)
            }
        }
    }

    public func setEmissiveTexture(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._emissiveSamplerProp, value)
    }

    /// Occlusion texture.
    public var occlusionTexture: MTLTexture? {
        get {
            _occlusionTexture
        }
        set {
            _occlusionTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._occlusionTextureProp, PBRBaseMaterial._occlusionSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_OCCLUSION_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_OCCLUSION_TEXTURE)
            }
        }
    }

    public func setOcclusionSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._occlusionSamplerProp, value)
    }

    /// Occlusion texture intensity.
    public var occlusionTextureIntensity: Float {
        get {
            _pbrBaseData.occlusionTextureIntensity
        }

        set {
            _pbrBaseData.occlusionTextureIntensity = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// Occlusion texture uv coordinate.
    public var occlusionTextureCoord: TextureCoordinate {
        get {
            _pbrBaseData.occlusionTextureCoord
        }

        set {
            _pbrBaseData.occlusionTextureCoord = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// Tiling and offset of main textures.
    public var tilingOffset: Vector4 {
        get {
            _pbrBaseData.tilingOffset
        }

        set {
            _pbrBaseData.tilingOffset = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// The clearCoat layer intensity, default 0.
    public var clearCoat: Float {
        get {
            _pbrBaseData.clearCoat
        }

        set {
            _pbrBaseData.clearCoat = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
            if newValue == 0 {
                shaderData.disableMacro(IS_CLEARCOAT)
            } else {
                shaderData.enableMacro(IS_CLEARCOAT)
            }
        }
    }

    /// The clearCoat layer intensity texture.
    public var clearCoatTexture: MTLTexture? {
        get {
            _clearCoatTexture
        }
        set {
            _clearCoatTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._clearCoatTextureProp, PBRBaseMaterial._clearCoatSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_TEXTURE)
            }
        }
    }

    public func setClearCoatSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._clearCoatSamplerProp, value)
    }

    /// The clearCoat layer roughness, default 0.
    public var clearCoatRoughness: Float {
        get {
            _pbrBaseData.clearCoatRoughness
        }

        set {
            _pbrBaseData.clearCoatRoughness = newValue
            shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
        }
    }

    /// The clearCoat layer roughness texture.
    public var clearCoatRoughnessTexture: MTLTexture? {
        get {
            _clearCoatRoughnessTexture
        }
        set {
            _clearCoatRoughnessTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._clearCoatRoughnessTextureProp, PBRBaseMaterial._clearCoatRoughnessSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_ROUGHNESS_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_ROUGHNESS_TEXTURE)
            }
        }
    }

    public func setClearCoatRoughnessSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._clearCoatRoughnessSamplerProp, value)
    }

    /// The clearCoat normal map texture.
    public var clearCoatNormalTexture: MTLTexture? {
        get {
            _clearCoatNormalTexture
        }
        set {
            _clearCoatNormalTexture = newValue
            shaderData.setImageView(PBRBaseMaterial._clearCoatNormalTextureProp, PBRBaseMaterial._clearCoatNormalSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_CLEARCOAT_NORMAL_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_CLEARCOAT_NORMAL_TEXTURE)
            }
        }
    }

    public func setClearCoatNormalSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRBaseMaterial._clearCoatNormalSamplerProp, value)
    }

    public override init(_ device: MTLDevice, _ name: String = "") {
        super.init(device, name)
        shaderData.enableMacro(NEED_WORLDPOS)
        shaderData.enableMacro(NEED_TILINGOFFSET)
        shaderData.setData(PBRBaseMaterial._pbrBaseProp, _pbrBaseData)
    }
}
