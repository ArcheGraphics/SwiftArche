//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Render element.
struct RenderElement {
    /// Render component.
    var renderer: Renderer
    /// Material.
    var material: Material
    /// Shader Pass
    var shaderPass: ShaderPass
    /// Mesh.
    var mesh: Mesh
    /// Sub mesh.
    var subMesh: SubMesh

    init(_ renderer: Renderer, _ mesh: Mesh, _ subMesh: SubMesh, _ material: Material, _ shaderPass: ShaderPass) {
        self.renderer = renderer
        self.mesh = mesh
        self.subMesh = subMesh
        self.material = material
        self.shaderPass = shaderPass
    }
}
