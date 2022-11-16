//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

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
            shaderData.setData(UnlitMaterial._baseColorProp, newValue)
        }
    }

    /// Base texture.
    public var baseTexture: MTLTexture? {
        get {
            _baseTexture
        }
        set {
            _baseTexture = newValue
            shaderData.setImageView(UnlitMaterial._baseTextureProp, UnlitMaterial._baseSamplerProp, newValue)
            if newValue != nil {
                shaderData.enableMacro(HAS_BASE_TEXTURE)
            } else {
                shaderData.disableMacro(HAS_BASE_TEXTURE)
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

    public init(_ engine: Engine, _ name: String) {
        super.init(engine.device, name)
        shader.append(ShaderPass(engine.library, "vertex_unlit", "fragment_unlit"))

        shaderData.enableMacro(OMIT_NORMAL)
        shaderData.enableMacro(NEED_TILINGOFFSET)

        shaderData.setData(UnlitMaterial._baseColorProp, _baseColor)
        shaderData.setData(UnlitMaterial._tilingOffsetProp, _tilingOffset)
    }
}
