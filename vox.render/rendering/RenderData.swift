//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol RenderData {
    var renderer: Renderer {get set}
    var material: Material {get set}
    var multiRenderData: Bool {get set}
}

public struct MeshRenderData: RenderData {
    public var renderer: Renderer
    public var material: Material
    public var multiRenderData: Bool = false
    
    public var mesh: Mesh
    public var subMesh: SubMesh
    
    public init(renderer: Renderer, material: Material, mesh: Mesh, subMesh: SubMesh) {
        self.renderer = renderer
        self.material = material
        self.mesh = mesh
        self.subMesh = subMesh
    }
}

public struct TextRenderData: RenderData {
    public var renderer: Renderer
    public var material: Material
    public var multiRenderData: Bool = true
    
    /// sprite texture
    public var texture: MTLTexture?
    
    /// 2D Sprite Element
    public init(_ renderer: Renderer, _ material: Material, _ texture: MTLTexture) {
        self.renderer = renderer
        self.texture = texture
        self.material = material
    }
}
