//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

public class TransparentShadowMaterial: BaseMaterial {
    private var _baseColor = Color(1, 1, 1, 1)

    /// Base color.
    public var baseColor: Color {
        get {
            _baseColor
        }
        set {
            _baseColor = newValue
            shaderData.setData(TransparentShadowMaterial._baseColorProp, newValue.toLinear())
        }
    }
    
    public init(_ engine: Engine, _ name: String = "") {
        super.init(engine.device, name)
        shader.append(ShaderPass(engine.library(), "vertex_unlit_worldPos", "fragment_transparent_shadow"))
        shaderData.enableMacro(NEED_WORLDPOS.rawValue)
        shaderData.setData(TransparentShadowMaterial._baseColorProp, _baseColor)
    }
}
