//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Material.
open class Material {
    var _shader: Shader

    /// Name.
    public var name: String = ""
    /// Shader data.
    public var shaderData: ShaderData
    /// Render states.
    public var renderStates: [RenderState] = []

    /// Shader used by the material.
    public var shader: Shader {
        get {
            _shader
        }
        set {
            _shader = newValue
            let lastStatesCount = renderStates.count

            var maxPassCount = 0
            let subShaders = shader.subShaders
            for i in 0..<subShaders.count {
                maxPassCount = max(subShaders[i].passes.count, maxPassCount)
            }

            if (lastStatesCount < maxPassCount) {
                for _ in lastStatesCount..<maxPassCount {
                    renderStates.append(RenderState())
                }
            } else {
                renderStates = renderStates.dropLast(renderStates.count - maxPassCount)
            }
        }
    }

    /// Create a material instance.
    /// - Parameters:
    ///   - device: Metal Device
    ///   - name: Material name
    public init(shader: Shader, _ name: String = "") {
        _shader = shader
        shaderData = ShaderData()
        self.name = name
        
        self.shader = _shader
    }
}
