//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#if os(macOS)
import AppKit

extension NSFont {
    var estimatedLineWidth: CGFloat {
        let string: NSString = "!"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: self])
        return .init(ceilf(.init(stringSize.width)))
    }

    var estimatedGlyphSize: CGSize {
        let string: NSString = "{ǺOJMQYZa@jmqyw"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: self])
        let averageGlyphWidth = CGFloat(ceilf(.init(stringSize.width) / .init(string.length)))
        let maxGlyphHeight = CGFloat(ceilf(.init(stringSize.height)))
        return CGSize(width: averageGlyphWidth, height: maxGlyphHeight)
    }

    var ctFont: CTFont {
        CTFontCreateWithName(fontName as CFString, pointSize, nil)
    }

    private static func stringWithFontFitsInRect(font: NSFont,
                                                 rect: CGRect,
                                                 characterCount: Int) -> Bool {
        let area = rect.size.width * rect.size.height
        let glyphMargin = font.estimatedLineWidth
        let averageGlyphSize = font.estimatedGlyphSize
        let estimatedGlyphTotalArea = (averageGlyphSize.width + glyphMargin)
                * (averageGlyphSize.height + glyphMargin)
                * .init(characterCount)
        return estimatedGlyphTotalArea < area
    }

    public static func atlasFont(name fontName: String, atlasRect: CGRect,
                                 trialFontSize: CGFloat = 32) -> NSFont? {
        guard let temporaryFont = NSFont(name: fontName, size: 8)
        else {
            return nil
        }
        let glyphCount = CTFontGetGlyphCount(temporaryFont.ctFont)
        let fittedPointSize = Self.calculateFontSizeToFit(rect: atlasRect,
                fontName: fontName,
                characterCount: glyphCount,
                trialFontSize: trialFontSize)

        return NSFont(name: fontName,
                size: fittedPointSize)
    }

    public static func calculateFontSizeToFit(rect: CGRect,
                                              fontName: String,
                                              characterCount: Int,
                                              trialFontSize: CGFloat = 32) -> CGFloat {
        var fittedSize = trialFontSize
        while let trialFont = NSFont(name: fontName, size: fittedSize),
              NSFont.stringWithFontFitsInRect(font: trialFont, rect: rect,
                      characterCount: characterCount) {
            fittedSize += 1
        }

        while let trialFont = NSFont(name: fontName, size: fittedSize),
              !NSFont.stringWithFontFitsInRect(font: trialFont, rect: rect,
                      characterCount: characterCount) {
            fittedSize -= 1
        }
        return fittedSize
    }
}
#endif

// MARK: -

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

extension UIFont {
    var estimatedLineWidth: CGFloat {
        let string: NSString = "!"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: self])
        return .init(ceilf(.init(stringSize.width)))
    }

    var estimatedGlyphSize: CGSize {
        let string: NSString = "{ǺOJMQYZa@jmqyw"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: self])
        let averageGlyphWidth = CGFloat(ceilf(.init(stringSize.width) / .init(string.length)))
        let maxGlyphHeight = CGFloat(ceilf(.init(stringSize.height)))
        return CGSize(width: averageGlyphWidth, height: maxGlyphHeight)
    }

    var ctFont: CTFont {
        CTFontCreateWithName(self.fontName as CFString, self.pointSize, nil)
    }

    private static func stringWithFontFitsInRect(font: UIFont,
                                                 rect: CGRect,
                                                 characterCount: Int) -> Bool {
        let area = rect.size.width * rect.size.height
        let glyphMargin = font.estimatedLineWidth
        let averageGlyphSize = font.estimatedGlyphSize
        let estimatedGlyphTotalArea = (averageGlyphSize.width + glyphMargin)
                * (averageGlyphSize.height + glyphMargin)
                * .init(characterCount)
        return estimatedGlyphTotalArea < area
    }

    public static func atlasFont(name fontName: String,
                                 atlasRect: CGRect,
                                 trialFontSize: CGFloat = 32) -> UIFont? {
        guard let temporaryFont = UIFont(name: fontName, size: 8)
        else {
            return nil
        }
        let glyphCount = CTFontGetGlyphCount(temporaryFont.ctFont)
        let fittedPointSize = Self.calculateFontSizeToFit(rect: atlasRect, fontName: fontName, characterCount: glyphCount, trialFontSize: trialFontSize)

        return UIFont(name: fontName,
                size: fittedPointSize)
    }

    public static func calculateFontSizeToFit(rect: CGRect,
                                              fontName: String,
                                              characterCount: Int,
                                              trialFontSize: CGFloat = 32) -> CGFloat {
        var fittedSize = trialFontSize
        while let trialFont = UIFont(name: fontName, size: fittedSize),
              UIFont.stringWithFontFitsInRect(font: trialFont, rect: rect,
                      characterCount: characterCount) {
            fittedSize += 1
        }

        while let trialFont = UIFont(name: fontName, size: fittedSize),
              !UIFont.stringWithFontFitsInRect(font: trialFont, rect: rect,
                      characterCount: characterCount) {
            fittedSize -= 1
        }
        return fittedSize
    }
}
#endif
