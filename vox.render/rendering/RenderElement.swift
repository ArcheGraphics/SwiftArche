//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Render element.
public struct RenderElement {
    /// Render component.
    public var renderer: Renderer
    /// Material.
    public var material: Material
    /// Shader Pass
    public var shaderPass: ShaderPass
    /// Mesh.
    public var mesh: Mesh?
    /// Sub mesh.
    public var subMesh: SubMesh?
    /// sprite texture
    public var texture: MTLTexture?
    
    /// 2D Sprite Element
    public init(_ renderer: Renderer, _ texture: MTLTexture, _ material: Material, _ shaderPass: ShaderPass) {
        self.renderer = renderer
        self.texture = texture
        self.material = material
        self.shaderPass = shaderPass
    }

    /// 3D Mesh Element
    public init(_ renderer: Renderer, _ mesh: Mesh, _ subMesh: SubMesh, _ material: Material, _ shaderPass: ShaderPass) {
        self.renderer = renderer
        self.mesh = mesh
        self.subMesh = subMesh
        self.material = material
        self.shaderPass = shaderPass
    }
}
