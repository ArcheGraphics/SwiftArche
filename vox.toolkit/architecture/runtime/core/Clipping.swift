//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Rect to line segment clipping implementation.
/// https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
class Clipping {
    public struct OutCode: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let Inside = OutCode([]) // 0000
        public static let Left = OutCode(rawValue: 1)   // 0001
        public static let Right = OutCode(rawValue: 2)  // 0010
        public static let Bottom = OutCode(rawValue: 4) // 0100
        public static let Top = OutCode(rawValue: 8)    // 1000
    }

    // Compute the bit code for a point (x, y) using the clip rectangle
    // bounded diagonally by (xmin, ymin), and (xmax, ymax)
    static func ComputeOutCode(rect: Rect, x: Float, y: Float) -> OutCode {
        var code = OutCode.Inside // initialised as being inside of [[clip window]]

        if (x < rect.xMin) { // to the left of clip window
            code.insert(OutCode.Left)
        } else if (x > rect.xMax) {// to the right of clip window
            code.insert(OutCode.Right)
        }
        if (y < rect.yMin) {// below the clip window
            code.insert(OutCode.Bottom)
        } else if (y > rect.yMax) {// above the clip window
            code.insert(OutCode.Top)
        }

        return code
    }

    // Cohen–Sutherland clipping algorithm clips a line from
    // P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with
    // diagonal from (xmin, ymin) to (xmax, ymax).
    internal static func RectContainsLineSegment(rect: Rect, x0: Float, y0: Float, x1: Float, y1: Float) -> Bool {
        false
    }
}
