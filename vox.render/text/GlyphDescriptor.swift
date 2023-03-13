//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import CoreGraphics
import CoreText

public struct GlyphDescriptor {
    var glyphIndex: CGGlyph
    var topLeftCoordinate: SIMD2<Float>
    var bottomRightCoordinate: SIMD2<Float>

    public init(glyphIndex: UInt,
                topLeftCoordinate: SIMD2<Float>,
                bottomRightCoordinate: SIMD2<Float>) {
        self.glyphIndex = CGGlyph(glyphIndex)
        self.topLeftCoordinate = topLeftCoordinate
        self.bottomRightCoordinate = bottomRightCoordinate
    }
}

extension GlyphDescriptor: Codable { }
