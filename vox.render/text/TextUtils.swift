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
#else
    import UIKit
#endif

class TextUtils {
    static func textUpdate(fontSize: Float, fontAtlas: MTLFontAtlas, string: String,
                           vertices: inout [Vector3], texCoords: inout [Vector2], indices: inout [UInt32],
                           bounds: inout BoundingBox)
    {
        #if os(iOS) || targetEnvironment(macCatalyst)
            let textRect = CGRectInset(UIScreen.main.accessibilityFrame, 0, 0) // RG: text x,y from top left
            let font = UIFont(name: fontAtlas.font.fontName, size: CGFloat(fontSize))!
        #else
            let textRect = CGRectInset(NSScreen.main!.visibleFrame, 0, 0) // RG: text x,y from top left
            let font = NSFont(name: fontAtlas.font.fontName, size: CGFloat(fontSize))!
        #endif
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [NSAttributedString.Key.font: font])
        let stringRange = CFRangeMake(0, attributedString.length)
        let rectPath = CGPath(rect: textRect, transform: nil)

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

        enumerateGlyphs(in: frame) { glyph, glyphIndex, glyphBounds in
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
        bounds = BoundingBox.fromPoints(points: vertices)
        vertices = vertices.map { v in
            var vertice = v - bounds.center
            vertice.y *= -1
            return vertice
        }
        bounds.center = Vector3()
    }

    private static func enumerateGlyphs(in frame: CTFrame,
                                        block: (_ glyph: CGGlyph,
                                                _ glyphIndex: Int,
                                                _ glyphBounds: CGRect) -> Void)
    {
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

            runs.enumerated().forEach { _, run in
                let glyphCount = CTRunGetGlyphCount(run)
                var glyphBuffer = [CGGlyph](repeating: .init(),
                                            count: glyphCount)
                CTRunGetGlyphs(run, entire, &glyphBuffer)

                var positionBuffer = [CGPoint](repeating: .zero, count: glyphCount)
                CTRunGetPositions(run, entire, &positionBuffer)

                for glyphIndex in 0 ..< glyphCount {
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
