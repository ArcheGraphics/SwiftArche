//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

final public class MTLFontAtlasCodableContainer: Codable {
    private let fontName: String
    private let fontSize: CGFloat
    private let glyphDescriptors: [GlyphDescriptor]
    private let fontAtlasTextureCodableBox: MTLTextureCodableBox

    public init(fontAtlas: MTLFontAtlas) throws {
        self.fontName = fontAtlas.font.fontName
        self.fontSize = fontAtlas.font.pointSize
        self.glyphDescriptors = fontAtlas.glyphDescriptors
        self.fontAtlasTextureCodableBox = try fontAtlas.fontAtlasTexture.codable()
    }

    public func fontAtlas(device: MTLDevice) throws -> MTLFontAtlas {
        return try .init(font: .init(name: self.fontName,
                                     size: self.fontSize)!,
                         glyphDescriptors: self.glyphDescriptors,
                         fontAtlasTexture: self.fontAtlasTextureCodableBox
                                               .texture(device: device))
    }
}
