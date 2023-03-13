//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import Math

/// Unlit Material.
public class UnlitMaterial: BaseMaterial {
    private var _baseColor = Color(1, 1, 1, 1)
    private var _baseTexture: MTLTexture?
    private var _tilingOffset = Vector4(1, 1, 0, 0)

    /// Base color.
    public var baseColor: Color {
        get {
            _baseColor
        }
        set {
            _baseColor = newValue
            shaderData.setData(UnlitMaterial._baseColorProp, newValue.toLinear())
        }
    }

    /// Base texture.
    public var baseTexture: MTLTexture? {
        get {
            _baseTexture
        }
        set {
            _baseTexture = newValue
            if let newValue = newValue {
                shaderData.setImageView(UnlitMaterial._baseTextureProp, UnlitMaterial._baseSamplerProp,
                                        newValue.makeTextureView(pixelFormat: .bgra8Unorm_srgb))
                shaderData.enableMacro(HAS_BASE_TEXTURE.rawValue)
            } else {
                shaderData.setImageView(UnlitMaterial._baseTextureProp, UnlitMaterial._baseSamplerProp, nil)
                shaderData.disableMacro(HAS_BASE_TEXTURE.rawValue)
            }
        }
    }

    /// Tiling and offset of main textures.
    public var tilingOffset: Vector4 {
        get {
            _tilingOffset
        }
        set {
            _tilingOffset = newValue
            shaderData.setData(UnlitMaterial._tilingOffsetProp, newValue)
        }
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library(), "vertex_unlit", "fragment_unlit"))

        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)

        shaderData.setData(UnlitMaterial._baseColorProp, _baseColor)
        shaderData.setData(UnlitMaterial._tilingOffsetProp, _tilingOffset)
    }
}
