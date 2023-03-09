//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import AppKit.NSFont

final public class MTLFontAtlas {
    let font: NSFont
    let glyphDescriptors: [GlyphDescriptor]
    let fontAtlasTexture: MTLTexture

    public init(font: NSFont,
                glyphDescriptors: [GlyphDescriptor],
                fontAtlasTexture: MTLTexture) {
        self.font = font
        self.glyphDescriptors = glyphDescriptors
        self.fontAtlasTexture = fontAtlasTexture
    }

    public func codable() throws -> MTLFontAtlasCodableContainer {
        return try .init(fontAtlas: self)
    }
}
