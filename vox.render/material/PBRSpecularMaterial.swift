//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

public class PBRSpecularMaterial: PBRBaseMaterial {
    private var _pbrSpecularData = PBRSpecularData(specularColor: vector_float3(1, 1, 1), glossiness: 1)
    private static var _pbrSpecularProp = "u_pbrSpecular"

    private var _specularGlossinessTexture: MTLTexture?
    private static var _specularGlossinessTextureProp = "u_specularGlossinessTexture"
    private static var _specularGlossinessSamplerProp = "u_specularGlossinessSampler"

    /// Specular color.
    public var specularColor: Color {
        get {
            Color(_pbrSpecularData.specularColor, 1.0).toGamma()
        }

        set {
            _pbrSpecularData.specularColor = newValue.toLinear().rgb
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
                shaderData.enableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            } else {
                shaderData.disableMacro(HAS_ROUGHNESS_METALLIC_TEXTURE.rawValue)
            }
        }
    }

    public func setSpecularGlossinessSampler(value: MTLSamplerDescriptor) {
        shaderData.setSampler(PBRSpecularMaterial._specularGlossinessSamplerProp, value)
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shaderData.setData(PBRSpecularMaterial._pbrSpecularProp, _pbrSpecularData)
    }
}
