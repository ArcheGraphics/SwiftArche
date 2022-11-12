//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Material.
class Material {
    /// Name.
    var name: String = ""
    /// Shader data.
    var shaderData: ShaderData

    /// Shader used by the material.
    var shader: [ShaderPass] = []

    func getRenderState(_ index: Int) -> RenderState {
        shader[index].renderState!
    }

    /// Create a material instance.
    /// - Parameters:
    ///   - device: Metal Device
    init(_ device: MTLDevice) {
        shaderData = ShaderData(device)
    }
}
