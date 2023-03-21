//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import CoreGraphics
import CoreText
#if os(macOS)
import AppKit
#endif

public class TextRenderer: Renderer {
    static var _defaultMaterial: Material!
    
    private var _string: String = ""
    private var _fontAtlas: MTLFontAtlas?
    private var _fontSize: Float = 1
    private var _color = Color()
    private var _isDirty: Bool = false

    var vertices: [Vector3] = []
    var texCoords: [Vector2] = []
    var worldVertice: [Vector3] = []
    var indices: [UInt32] = []

    public var maskLayer: Layer = Layer.Layer0
    
    /// text color
    public var color: Color {
        get {
            _color
        }
        set {
            _color = newValue
            shaderData.setData("u_color", _color)
        }
    }
    
    /// text string
    public var string: String {
        get {
            _string
        }
        set {
            if _string != newValue {
                _string = newValue
                _isDirty = true
            }
        }
    }
    
    /// font atlas
    public var fontAtlas: MTLFontAtlas? {
        get {
            _fontAtlas
        }
        set {
            if _fontAtlas !== newValue {
                _fontAtlas = newValue
                _isDirty = true
            }
        }
    }
    
    /// font size
    public var fontSize: Float {
        get {
            _fontSize
        }
        set {
            if _fontSize != newValue {
                _fontSize = newValue
                _isDirty = true
            }
        }
    }
    
    required init() {
        super.init()
        setMaterial(TextRenderer._defaultMaterial)
    }
    
    enum CodingKeys: String, CodingKey {
        case color
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        setMaterial(TextRenderer._defaultMaterial)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    override func _render(_ devicePipeline: DevicePipeline) {
        if (_dirtyUpdateFlag & RendererUpdateFlags.WorldVolume.rawValue != 0) {
            worldVertice = vertices.map({ v in
                Vector3.transformCoordinate(v: v, m: entity.transform.worldMatrix)
            })
        }
        if let fontAtlas {
            let mtl = _materials[0]!
            devicePipeline.pushPrimitive(RenderElement(self, fontAtlas.fontAtlasTexture, mtl, mtl.shader[0]))
        }
    }

    override func update(_ deltaTime: Float) {
        if let fontAtlas,
           _isDirty {
            TextUtils.textUpdate(fontSize: fontSize, fontAtlas: fontAtlas, string: string,
                                 vertices: &vertices, texCoords: &texCoords,
                                 indices: &indices, bounds: &_bounds)
            
            worldVertice = vertices.map({ v in
                Vector3.transformCoordinate(v: v, m: entity.transform.worldMatrix)
            })
            _isDirty = false
        }
    }
}
