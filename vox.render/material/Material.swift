//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Material.
open class Material: Serializable {
    /// Name.
    public var name: String = ""
    /// Shader data.
    public var shaderData: ShaderData
    /// Render states.
    public var renderStates: [RenderState] = []

    /// Shader used by the material.
    public var shader: Shader? {
        didSet {
            _updateRenderState()
        }
    }

    /// Create a material instance.
    public required init() {
        shaderData = ShaderData(group: .Material)
    }

    func _updateRenderState() {
        if let shader {
            let lastStatesCount = renderStates.count

            var maxPassCount = 0
            let subShaders = shader.subShaders
            for i in 0 ..< subShaders.count {
                maxPassCount = max(subShaders[i].passes.count, maxPassCount)
            }

            if lastStatesCount < maxPassCount {
                for _ in lastStatesCount ..< maxPassCount {
                    renderStates.append(RenderState())
                }
            } else {
                renderStates = renderStates.dropLast(renderStates.count - maxPassCount)
            }
        }
    }
}
