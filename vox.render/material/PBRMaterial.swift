//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// PBR (Metallic-Roughness Workflow) Material.
public class PBRMaterial: PBRBaseMaterial {
    struct PBRData {
        var metallic: Float = 1
        var roughness: Float = 1
        // aligned pad
        var pad1: Float = 0
        var pad2: Float = 0
    }

    private var _pbrData = PBRData()
    private static let _pbrProp = "u_pbrProp"

    private var _metallicRoughnessTexture: MTLTexture?
    private static let _roughnessMetallicTextureProp = "u_roughnessMetallicTexture"
    private static let _roughnessMetallicSamplerProp = "u_roughnessMetallicSampler"

    /// Metallic, default 1.0.
    public var metallic: Float {
        get {
            _pbrData.metallic
        }

        set {
            _pbrData.metallic = newValue
            shaderData.setData(PBRMaterial._pbrProp, _pbrData)
        }
    }

    /// Roughness, default 1.0.
    public var roughness: Float {
        get {
            _pbrData.roughness
        }

        set {
            _pbrData.roughness = newValue
            shaderData.setData(PBRMaterial._pbrProp, _pbrData)
        }
    }

    /// Roughness metallic texture.
    public var roughnessMetallicTexture: MTLTexture? {
        get {
            _metallicRoughnessTexture
        }
        set {
            _metallicRoughnessTexture = newValue
            shaderData.setImageView(PBRMaterial._roughnessMetallicTextureProp, PBRMaterial._roughnessMetallicSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE)
            }
        }
    }

    public func setRoughnessMetallicSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRMaterial._roughnessMetallicSamplerProp, value)
    }

    public override init(_ device: MTLDevice, _ name: String = "") {
        super.init(device, name)
        shaderData.setData(PBRMaterial._pbrProp, _pbrData)
    }
}
