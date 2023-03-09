//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#if os(macOS)
import AppKit
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

final public class MTLFontAtlasProvider {
    public enum Error: Swift.Error {
        case fontCreationFailed
    }

    // MARK: - Properties
    public let engine: Engine

    let function: MTLFunction!
    let pipelineState: MTLComputePipelineState!

    private let sourceFontAtlasSize = 4096
    private var atlasCache: [MTLFontAtlasDescriptor: MTLFontAtlas] = [:]

    // MARK: - Init

    /// Create a signed-distance field based font atlas with the specified dimensions.
    /// The supplied font will be resized to fit all available glyphs in the texture.
    public init(engine: Engine) throws {
        self.engine = engine
        function = engine.library("vox.shader").makeFunction(name: "quantizeDistanceField")!
        pipelineState = try! engine.device.makeComputePipelineState(function: function)

//        let defaultAtlas = try JSONDecoder().decode(MTLFontAtlasCodableContainer.self,
//                        from: .init(contentsOf: Self.defaultAtlasFileURL))
//                .fontAtlas(device: engine.device)
//        atlasCache[Self.defaultAtlasDescriptor] = defaultAtlas
    }

    /// Provide font atlas
    /// - Parameter descriptor: font atlas descriptor.
    public func fontAtlas(descriptor: MTLFontAtlasDescriptor) throws -> MTLFontAtlas {
        if atlasCache[descriptor] == nil {
            atlasCache[descriptor] = try createAtlas(descriptor: descriptor)
        }
        return atlasCache[descriptor]!
    }

    #if os(macOS)
    private func createFontAtlasData(font: NSFont, width: Int, height: Int) -> (data: [UInt8], descriptors: [GlyphDescriptor]) {

        var data = [UInt8](repeating: .zero,
                count: width * height)
        var glyphDescriptors: [GlyphDescriptor] = []

        let context = CGContext(data: &data,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue)!

        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        context.setAllowsAntialiasing(false)

        // Flip context coordinate space so y increases downward
        context.translateBy(x: .zero, y: .init(height))
        context.scaleBy(x: 1, y: -1)

        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        // Fill the context with an opaque black color
        context.setFillColor(NSColor.black.cgColor)
        context.fill(rect)

        let ctFont = font.ctFont
        let fontGlyphCount = CTFontGetGlyphCount(ctFont)
        let glyphMargin = font.estimatedLineWidth

        // Set fill color so that glyphs are solid white
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)

        let fontAscent = CTFontGetAscent(ctFont)
        let fontDescent = CTFontGetDescent(ctFont)

        var origin = CGPoint(x: 0, y: fontAscent)

        var maxYCoordForLine: CGFloat = -1

        let glyphIndices = (0..<fontGlyphCount).map {
            CGGlyph($0)
        }

        for var glyphIndex in glyphIndices {
            var boundingRect = CGRect()

            CTFontGetBoundingRectsForGlyphs(ctFont, .horizontal, &glyphIndex, &boundingRect, 1)

            if (origin.x + boundingRect.maxX + glyphMargin) > .init(width) {
                origin.x = 0
                origin.y = maxYCoordForLine + glyphMargin + fontDescent
                maxYCoordForLine = -1
            }

            if (origin.y + boundingRect.maxY) > maxYCoordForLine {
                maxYCoordForLine = origin.y + boundingRect.maxY
            }

            let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
            let glyphOriginY = origin.y + (glyphMargin * 0.5)
            var glyphTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: glyphOriginX, ty: glyphOriginY)
            var glyphPathBoundingRect: CGRect = .zero

            if let path = CTFontCreatePathForGlyph(ctFont, glyphIndex, &glyphTransform) {
                context.addPath(path)
                context.fillPath()
                glyphPathBoundingRect = path.boundingBoxOfPath
            }

            let texCoordLeft: Float = .init(glyphPathBoundingRect.origin.x) / .init(width)
            let texCoordRight: Float = .init((glyphPathBoundingRect.origin.x + glyphPathBoundingRect.size.width)) / .init(width)
            let texCoordTop: Float = .init((glyphPathBoundingRect.origin.y)) / .init(height)
            let texCoordBottom: Float = .init((glyphPathBoundingRect.origin.y + glyphPathBoundingRect.size.height)) / .init(height)

            let descriptor = GlyphDescriptor(glyphIndex: .init(glyphIndex), topLeftCoordinate: .init(texCoordLeft, texCoordTop),
                    bottomRightCoordinate: .init(texCoordRight, texCoordBottom))
            glyphDescriptors.append(descriptor)

            origin.x += boundingRect.width + glyphMargin
        }

        return (data, glyphDescriptors)
    }
    #endif

    #if os(iOS) || targetEnvironment(macCatalyst)
    private func createFontAtlasData(font: UIFont, width: Int, height: Int) -> (data: [UInt8], descriptors: [GlyphDescriptor]) {
        var data = [UInt8](repeating: .zero, count: width * height)
        var glyphDescriptors: [GlyphDescriptor] = []

        let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue)!

        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        context.setAllowsAntialiasing(false)

        // Flip context coordinate space so y increases downward
        context.translateBy(x: .zero, y: .init(height))
        context.scaleBy(x: 1, y: -1)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)

        // Fill the context with an opaque black color
        context.setFillColor(NSColor.black.cgColor)
        context.fill(rect)

        let ctFont = font.ctFont
        let fontGlyphCount = CTFontGetGlyphCount(ctFont)
        let glyphMargin = font.estimatedLineWidth

        // Set fill color so that glyphs are solid white
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)

        let fontAscent = CTFontGetAscent(ctFont)
        let fontDescent = CTFontGetDescent(ctFont)

        var origin = CGPoint(x: 0, y: fontAscent)

        var maxYCoordForLine: CGFloat = -1

        let glyphIndices = (0..<fontGlyphCount).map {
            CGGlyph($0)
        }

        for var glyphIndex in glyphIndices {
            var boundingRect = CGRect()

            CTFontGetBoundingRectsForGlyphs(ctFont, .horizontal, &glyphIndex, &boundingRect, 1)

            if (origin.x + boundingRect.maxX + glyphMargin) > .init(width) {
                origin.x = 0
                origin.y = maxYCoordForLine + glyphMargin + fontDescent
                maxYCoordForLine = -1
            }

            if (origin.y + boundingRect.maxY) > maxYCoordForLine {
                maxYCoordForLine = origin.y + boundingRect.maxY
            }

            let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
            let glyphOriginY = origin.y + (glyphMargin * 0.5)
            var glyphTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: glyphOriginX, ty: glyphOriginY)

            var glyphPathBoundingRect: CGRect = .zero

            if let path = CTFontCreatePathForGlyph(ctFont, glyphIndex, &glyphTransform) {
                context.addPath(path)
                context.fillPath()

                glyphPathBoundingRect = path.boundingBoxOfPath
            }

            let texCoordLeft: Float = .init(glyphPathBoundingRect.origin.x) / .init(width)
            let texCoordRight: Float = .init((glyphPathBoundingRect.origin.x + glyphPathBoundingRect.size.width)) / .init(width)
            let texCoordTop: Float = .init((glyphPathBoundingRect.origin.y)) / .init(height)
            let texCoordBottom: Float = .init((glyphPathBoundingRect.origin.y + glyphPathBoundingRect.size.height)) / .init(height)

            let descriptor = GlyphDescriptor(glyphIndex: .init(glyphIndex),
                    topLeftCoordinate: .init(texCoordLeft, texCoordTop),
                    bottomRightCoordinate: .init(texCoordRight, texCoordBottom))
            glyphDescriptors.append(descriptor)

            origin.x += boundingRect.width + glyphMargin
        }

        return (data, glyphDescriptors)
    }
    #endif

    private func createAtlas(descriptor: MTLFontAtlasDescriptor) throws -> MTLFontAtlas {
        #if os(macOS)
        guard let font = NSFont.atlasFont(name: descriptor.fontName, rectWidth: Float(sourceFontAtlasSize),
                                          rectHeight: Float(sourceFontAtlasSize))
        else {
            throw Error.fontCreationFailed
        }
        #endif

        #if os(iOS) || targetEnvironment(macCatalyst)
        guard let font = UIFont.atlasFont(name: descriptor.fontName, rectWidth: Float(sourceFontAtlasSize),
                                          rectHeight: Float(sourceFontAtlasSize))
        else {
            throw Error.fontCreationFailed
        }
        #endif

        var fontAtlasData = createFontAtlasData(font: font,
                width: sourceFontAtlasSize,
                height: sourceFontAtlasSize)

        let sdfFontAtlasPtr = createSignedDistanceFieldForGrayscaleImage(&fontAtlasData.data,
                                                                         sourceFontAtlasSize, sourceFontAtlasSize)
        var sdfFontAtlasData = Array(UnsafeBufferPointer(start: sdfFontAtlasPtr,
                                                         count: sourceFontAtlasSize * sourceFontAtlasSize))

        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = sourceFontAtlasSize
        textureDescriptor.height = sourceFontAtlasSize
        textureDescriptor.pixelFormat = .r32Float
        textureDescriptor.resourceOptions = []
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
#if os(macOS)
        textureDescriptor.storageMode = .managed
#endif
        guard let sdfFontAtlasTexture = engine.device.makeTexture(descriptor: textureDescriptor)
        else {
            throw MetalError.MTLDeviceError.textureCreationFailed
        }

        sdfFontAtlasTexture.replace(region: sdfFontAtlasTexture.region,
                mipmapLevel: 0,
                withBytes: &sdfFontAtlasData,
                bytesPerRow: sdfFontAtlasTexture.width * MemoryLayout<Float>.stride)

        textureDescriptor.width = descriptor.textureSize
        textureDescriptor.height = descriptor.textureSize
        textureDescriptor.pixelFormat = .r8Unorm
        textureDescriptor.mipmapLevelCount = Int(floor(log2(Float(descriptor.textureSize))))
        guard let fontAtlasTexture = engine.device.makeTexture(descriptor: textureDescriptor)
        else {
            throw MetalError.MTLDeviceError.textureCreationFailed
        }

        let fontAtlas = MTLFontAtlas(font: font,
                glyphDescriptors: fontAtlasData.descriptors,
                fontAtlasTexture: fontAtlasTexture)
        var fontSpread = Float(fontAtlas.font.estimatedLineWidth * 0.5)

        if let commandBuffer = engine.commandQueue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setTexture(sdfFontAtlasTexture, index: 0)
            commandEncoder.setTexture(fontAtlas.fontAtlasTexture, index: 1)
            commandEncoder.setBytes(&fontSpread, length: MemoryLayout<Float>.stride, index: 0)

            let w = pipelineState.threadExecutionWidth
            let h = pipelineState.maxTotalThreadsPerThreadgroup / w
            commandEncoder.dispatchThreads(fontAtlas.fontAtlasTexture.size,
                    threadsPerThreadgroup: MTLSize(width: w, height: h, depth: 1))
            commandEncoder.endEncoding()
            
            if let blit = commandBuffer.makeBlitCommandEncoder() {
                blit.generateMipmaps(for: fontAtlas.fontAtlasTexture)
                blit.endEncoding()
            }

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }

        return fontAtlas
    }

    private static let defaultAtlasFileURL = Bundle.main.url(forResource: "HelveticaNeue",
            withExtension: "mtlfontatlas")!
    public static let defaultAtlasDescriptor = MTLFontAtlasDescriptor(fontName: "HelveticaNeue", textureSize: 2048)

}
