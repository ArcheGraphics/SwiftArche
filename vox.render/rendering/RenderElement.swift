//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Render element.
public struct RenderElement {
    public var data: RenderData
    public var shaderPass: ShaderPass
    public var renderState: RenderState
    
    init(data: RenderData, shaderPass: ShaderPass, renderState: RenderState) {
        self.data = data
        self.shaderPass = shaderPass
        self.renderState = renderState
    }
}
