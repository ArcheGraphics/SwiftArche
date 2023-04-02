//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public enum RenderType {
    case Mesh
    case Terrian
    case Text
}

public protocol RenderData {
    var renderer: Renderer {get set}
    var material: Material {get set}
    var multiRenderData: Bool {get set}
    var renderType: RenderType {get}
}

public struct MeshRenderData: RenderData {
    public var renderType: RenderType = .Mesh
    
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
    public var renderType: RenderType = .Text

    public var renderer: Renderer
    public var material: Material
    public var multiRenderData: Bool = true
    
    /// sprite texture
    public var texture: MTLTexture?
    
    /// 2D Sprite Element
    public init(renderer: Renderer, material: Material, texture: MTLTexture) {
        self.renderer = renderer
        self.texture = texture
        self.material = material
    }
}
