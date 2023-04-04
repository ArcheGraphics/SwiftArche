//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public final class MTLFontAtlasCodableContainer: Codable {
    private let fontName: String
    private let fontSize: CGFloat
    private let glyphDescriptors: [GlyphDescriptor]
    private let fontAtlasTextureCodableBox: MTLTextureCodableBox

    public init(fontAtlas: MTLFontAtlas) throws {
        fontName = fontAtlas.font.fontName
        fontSize = fontAtlas.font.pointSize
        glyphDescriptors = fontAtlas.glyphDescriptors
        fontAtlasTextureCodableBox = try fontAtlas.fontAtlasTexture.codable()
    }

    public func fontAtlas(device: MTLDevice) throws -> MTLFontAtlas {
        return try .init(font: .init(name: fontName,
                                     size: fontSize)!,
                         glyphDescriptors: glyphDescriptors,
                         fontAtlasTexture: fontAtlasTextureCodableBox
                             .texture(device: device))
    }
}
