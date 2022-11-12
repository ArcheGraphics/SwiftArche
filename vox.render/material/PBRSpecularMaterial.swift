//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

public class PBRSpecularMaterial: PBRBaseMaterial {
    struct PBRSpecularData {
        var specularColor = Vector3(1, 1, 1)
        var glossiness: Float = 1
    }

    private var _pbrSpecularData = PBRSpecularData()
    private static var _pbrSpecularProp = "u_pbrSpecularData"

    private var _specularGlossinessTexture: MTLTexture?
    private static var _specularGlossinessTextureProp = "u_specularGlossinessTexture"
    private static var _specularGlossinessSamplerProp = "u_specularGlossinessSampler"

    /// Specular color.
    public var specularColor: Vector3 {
        get {
            _pbrSpecularData.specularColor
        }

        set {
            _pbrSpecularData.specularColor = newValue
            shaderData.setData(PBRSpecularMaterial._pbrSpecularProp, _pbrSpecularData)
        }
    }

    /// Glossiness.
    public var glossiness: Float {
        get {
            _pbrSpecularData.glossiness
        }

        set {
            _pbrSpecularData.glossiness = newValue
            shaderData.setData(PBRSpecularMaterial._pbrSpecularProp, _pbrSpecularData)
        }
    }

    /// Specular glossiness texture.
    public var specularGlossinessTexture: MTLTexture? {
        get {
            _specularGlossinessTexture
        }
        set {
            _specularGlossinessTexture = newValue
            shaderData.setImageView(PBRSpecularMaterial._specularGlossinessTextureProp, PBRSpecularMaterial._specularGlossinessSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE)
            }
        }
    }

    public func setSpecularGlossinessSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRSpecularMaterial._specularGlossinessSamplerProp, value)
    }

    public override init(_ device: MTLDevice, _ name: String = "") {
        super.init(device, name)
        shaderData.setData(PBRSpecularMaterial._pbrSpecularProp, _pbrSpecularData)
    }
}
