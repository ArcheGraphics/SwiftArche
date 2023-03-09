//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import CoreGraphics
import CoreText
#if os(macOS)
import AppKit
#endif

public class TextRenderer: Renderer {
    private var _string: String = ""
    private var _fontAtlas: MTLFontAtlas?
    private var _rectWidth: Float = 0
    private var _rectHeight: Float = 0
    private var _color = Color()
    private var _isDirty: Bool = false

    var vertices: [Vector3] = []
    var texCoords: [Vector2] = []
    var worldVertice: [Vector3] = []
    var indices: [UInt32] = []
    
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
    
    /// rect width
    public var rectWidth: Float {
        get {
            _rectWidth
        }
        set {
            if _rectWidth != newValue {
                _rectWidth = newValue
                _isDirty = true
            }
        }
    }
    
    /// rect height
    public var rectHeight: Float {
        get {
            _rectHeight
        }
        set {
            if _rectHeight == newValue {
                _rectHeight = newValue
                _isDirty = true
            }
        }
    }
    
    public required init(_ entity: Entity) {
        super.init(entity)
        let mtl = Material(engine, "default text")
        mtl.shader.append(ShaderPass(engine.library(), "vertex_text", "fragment_text"))
        setMaterial(mtl)
    }
    
    override func _render(_ devicePipeline: DevicePipeline) {
        if (_dirtyUpdateFlag & MeshRendererUpdateFlags.VertexElementMacro.rawValue != 0) {
            worldVertice = vertices.map({ v in
                Vector3.transformCoordinate(v: v, m: entity.transform.worldMatrix)
            })
        }
        let mtl = _materials[0]!
        devicePipeline.pushPrimitive(RenderElement(self, mtl, mtl.shader[0]))
    }

    override func update(_ deltaTime: Float) {
        if let fontAtlas,
           _isDirty {
            let fontSize = NSFont.calculateFontSizeToFit(rectWidth: rectWidth, rectHeight: rectHeight,
                    fontName: fontAtlas.font.fontName, characterCount: string.count)

            let font = NSFont(name: fontAtlas.font.fontName, size: fontSize)!
            let attributedString = NSAttributedString(string: string,
                    attributes: [NSAttributedString.Key.font: font])
            let stringRange = CFRangeMake(0, attributedString.length)
            let rectPath = CGPath(rect: CGRect(x: 0, y: 0, width: Int(rectWidth), height: Int(rectHeight)), transform: nil)

            let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
            let frame = CTFramesetterCreateFrame(framesetter, stringRange, rectPath, nil)

            var frameGlyphCount: CFIndex = 0
            let lines = CTFrameGetLines(frame) as! [CTLine]
            lines.forEach {
                frameGlyphCount += CTLineGetGlyphCount($0)
            }

            let vertexCount = frameGlyphCount * 4
            let indexCount = frameGlyphCount * 6

            vertices = [Vector3](repeating: .init(), count: vertexCount)
            texCoords = [Vector2](repeating: .init(), count: vertexCount)
            indices = [UInt32](repeating: .zero, count: indexCount)

            var v = Int()
            var i = Int()

            enumerateGlyphs(in: frame) { (glyph, glyphIndex, glyphBounds) in
                guard glyph < fontAtlas.glyphDescriptors.count
                else {
                    return
                }

                let glyphInfo = fontAtlas.glyphDescriptors[.init(glyph)]
                let minX: Float = .init(glyphBounds.minX)
                let maxX: Float = .init(glyphBounds.maxX)
                let minY: Float = .init(glyphBounds.minY)
                let maxY: Float = .init(glyphBounds.maxY)

                let minS = glyphInfo.topLeftCoordinate.x
                let maxS = glyphInfo.bottomRightCoordinate.x
                let minT = glyphInfo.topLeftCoordinate.y
                let maxT = glyphInfo.bottomRightCoordinate.y

                vertices[v] = Vector3(minX, maxY, 0)
                texCoords[v] = Vector2(minS, maxT)
                v += 1
                vertices[v] = Vector3(minX, minY, 0)
                texCoords[v] = Vector2(minS, minT)
                v += 1
                vertices[v] = Vector3(maxX, minY, 0)
                texCoords[v] = Vector2(maxS, minT)
                v += 1
                vertices[v] = Vector3(maxX, maxY, 0)
                texCoords[v] = Vector2(maxS, maxT)
                v += 1

                indices[i] = .init(glyphIndex) * 4
                i += 1
                indices[i] = .init(glyphIndex) * 4 + 1
                i += 1
                indices[i] = .init(glyphIndex) * 4 + 2
                i += 1
                indices[i] = .init(glyphIndex) * 4 + 2
                i += 1
                indices[i] = .init(glyphIndex) * 4 + 3
                i += 1
                indices[i] = .init(glyphIndex) * 4
                i += 1
            }
            _bounds = BoundingBox.fromPoints(points: vertices)
            _isDirty = false
        }
    }

    private func enumerateGlyphs(in frame: CTFrame,
                                 block: (_ glyph: CGGlyph,
                                         _ glyphIndex: Int,
                                         _ glyphBounds: CGRect) -> Void) {
        let entire = CFRangeMake(0, 0)

        let framePath = CTFrameGetPath(frame)
        let frameBoundingRect = framePath.boundingBox

        let lines = CTFrameGetLines(frame) as! [CTLine]

        var lineOriginBuffer = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, entire, &lineOriginBuffer)

        var glyphIndexInFrame = CFIndex()

        #if os(iOS) || targetEnvironment(macCatalyst)
        UIGraphicsBeginImageContext(.init(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        #endif

        #if os(macOS)
        let context = CGContext(data: nil, width: 4096, height: 4096,
                bitsPerComponent: 8, bytesPerRow: 4096 * 4,
                space: NSColorSpace.genericRGB.cgColorSpace!,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        #endif

        lines.enumerated().forEach { lineIndex, line in
            let lineOrigin = lineOriginBuffer[lineIndex]
            let runs = CTLineGetGlyphRuns(line) as! [CTRun]

            runs.enumerated().forEach { runIndex, run in
                let glyphCount = CTRunGetGlyphCount(run)
                var glyphBuffer = [CGGlyph](repeating: .init(),
                        count: glyphCount)
                CTRunGetGlyphs(run, entire, &glyphBuffer)

                var positionBuffer = [CGPoint](repeating: .zero, count: glyphCount)
                CTRunGetPositions(run, entire, &positionBuffer)

                for glyphIndex in 0..<glyphCount {
                    let glyph = glyphBuffer[glyphIndex]
                    let glyphOrigin = positionBuffer[glyphIndex]
                    var glyphRect = CTRunGetImageBounds(run, context, CFRangeMake(glyphIndex, 1))
                    let boundsTransX = frameBoundingRect.origin.x + lineOrigin.x
                    let boundsTransY = frameBoundingRect.height + frameBoundingRect.origin.y - lineOrigin.y + glyphOrigin.y
                    let pathTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: boundsTransX, ty: boundsTransY)
                    glyphRect = glyphRect.applying(pathTransform)

                    block(glyph, glyphIndexInFrame, glyphRect)

                    glyphIndexInFrame += 1
                }
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        UIGraphicsEndImageContext()
        #endif
    }
}
