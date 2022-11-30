//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// PBR (Metallic-Roughness Workflow) Material.
public class PBRMaterial: PBRBaseMaterial {
    private var _pbrData = PBRData(metallic: 1, roughness: 1, pad1: 0, pad2: 0)
    private static let _pbrProp = "u_pbr"

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
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            }
        }
    }

    public func setRoughnessMetallicSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRMaterial._roughnessMetallicSamplerProp, value)
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shaderData.enableMacro(IS_METALLIC_WORKFLOW.rawValue)
        shaderData.setData(PBRMaterial._pbrProp, _pbrData)
    }
}
