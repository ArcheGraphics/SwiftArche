//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import CoreGraphics
import CoreText
import Math
#if os(macOS)
    import AppKit
#endif

public class TextRenderer: Renderer {
    static var _defaultMaterial: Material!

    private var _isDirty: Bool = false

    var vertices: [Vector3] = []
    var texCoords: [Vector2] = []
    var worldVertice: [Vector3] = []
    var indices: [UInt32] = []

    public var maskLayer: Layer = .Layer0

    /// text color
    public var color: Color = .init() {
        didSet {
            shaderData.setData(with: "u_color", data: color)
        }
    }

    /// text string
    public var string: String = "" {
        didSet {
            _isDirty = true
        }
    }

    /// font atlas
    public var fontAtlas: MTLFontAtlas? {
        didSet {
            _isDirty = true
        }
    }

    /// font size
    public var fontSize: Float = 1 {
        didSet {
            _isDirty = true
        }
    }

    required init() {
        super.init()
        setMaterial(TextRenderer._defaultMaterial)
    }

    override func _render(_ devicePipeline: DevicePipeline) {
        if _dirtyUpdateFlag & RendererUpdateFlags.WorldVolume.rawValue != 0 {
            worldVertice = vertices.map { v in
                Vector3.transformCoordinate(v: v, m: entity.transform.worldMatrix)
            }
        }
        if let fontAtlas {
            let mtl = _materials[0]!
            let renderData = TextRenderData(renderer: self, material: mtl, texture: fontAtlas.fontAtlasTexture)
            devicePipeline.pushRenderData(renderData)
        }
    }

    override func update(_: Float) {
        if let fontAtlas,
           _isDirty
        {
            TextUtils.textUpdate(fontSize: fontSize, fontAtlas: fontAtlas, string: string,
                                 vertices: &vertices, texCoords: &texCoords,
                                 indices: &indices, bounds: &_bounds)

            worldVertice = vertices.map { v in
                Vector3.transformCoordinate(v: v, m: entity.transform.worldMatrix)
            }
            _isDirty = false
        }
    }
}
