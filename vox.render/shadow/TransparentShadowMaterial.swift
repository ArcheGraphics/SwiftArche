//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class TransparentShadowMaterial: BaseMaterial {
    private var _baseColor = Color(1, 1, 1, 1)

    /// Base color.
    public var baseColor: Color = Color(1, 1, 1, 1) {
        didSet {
            shaderData.setData(with: TransparentShadowMaterial._baseColorProp, data: baseColor.toLinear())
        }
    }
    
    public required init() {
        super.init()
        shader = Shader.create(in: Engine.library(), vertexSource: "vertex_unlit_worldPos",
                               fragmentSource: "fragment_transparent_shadow")
        name = "transparent shadow"
        isTransparent = true
        shaderData.enableMacro(NEED_WORLDPOS.rawValue)
        shaderData.setData(with: TransparentShadowMaterial._baseColorProp, data: baseColor.toLinear())
    }
}
