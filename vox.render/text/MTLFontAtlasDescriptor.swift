//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public struct MTLFontAtlasDescriptor: Hashable {
    let fontName: String
    let textureSize: Int

    public init(fontName: String,
                textureSize: Int) {
        self.fontName = fontName
        self.textureSize = textureSize
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.fontName)
        hasher.combine(self.textureSize)
    }

    public static func == (lhs: MTLFontAtlasDescriptor,
                           rhs: MTLFontAtlasDescriptor) -> Bool {
        return lhs.fontName == rhs.fontName
            && lhs.textureSize == rhs.textureSize
    }
}
