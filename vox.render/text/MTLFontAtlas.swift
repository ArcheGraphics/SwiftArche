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

final public class MTLFontAtlas {
    let glyphDescriptors: [GlyphDescriptor]
    let fontAtlasTexture: MTLTexture

#if os(macOS)
    let font: NSFont
    public init(font: NSFont,
                glyphDescriptors: [GlyphDescriptor],
                fontAtlasTexture: MTLTexture) {
        self.font = font
        self.glyphDescriptors = glyphDescriptors
        self.fontAtlasTexture = fontAtlasTexture
    }
#endif
#if os(iOS) || targetEnvironment(macCatalyst)
    let font: UIFont
    public init(font: UIFont,
                glyphDescriptors: [GlyphDescriptor],
                fontAtlasTexture: MTLTexture) {
        self.font = font
        self.glyphDescriptors = glyphDescriptors
        self.fontAtlasTexture = fontAtlasTexture
    }
#endif

    public func codable() throws -> MTLFontAtlasCodableContainer {
        try .init(fontAtlas: self)
    }
}
