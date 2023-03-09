//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import CoreGraphics
import CoreText

public struct GlyphDescriptor {
    var glyphIndex: CGGlyph
    var topLeftCoordinate: Vector2
    var bottomRightCoordinate: Vector2

    public init(glyphIndex: UInt,
                topLeftCoordinate: Vector2,
                bottomRightCoordinate: Vector2) {
        self.glyphIndex = CGGlyph(glyphIndex)
        self.topLeftCoordinate = topLeftCoordinate
        self.bottomRightCoordinate = bottomRightCoordinate
    }
}

extension GlyphDescriptor: Codable { }
