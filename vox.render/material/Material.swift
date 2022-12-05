//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Material.
open class Material {
    /// Name.
    public var name: String = ""
    /// Shader data.
    public var shaderData: ShaderData

    /// Shader used by the material.
    public var shader: [ShaderPass] = []

    public func getRenderState(_ index: Int) -> RenderState {
        shader[index].renderState!
    }

    /// Create a material instance.
    /// - Parameters:
    ///   - device: Metal Device
    ///   - name: Material name
    public init(_ engine: Engine, _ name: String = "") {
        shaderData = ShaderData(engine)
        self.name = name
    }
}
