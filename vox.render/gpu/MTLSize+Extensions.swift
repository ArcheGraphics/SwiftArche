//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLSize {
    init(repeating value: Int) {
        self.init(width: value,
                  height: value,
                  depth: value)
    }

    func clamped(to size: MTLSize) -> MTLSize {
        MTLSize(width: min(max(width, 0), size.width),
                height: min(max(height, 0), size.height),
                depth: min(max(depth, 0), size.depth))
    }

    static let one = MTLSize(repeating: 1)
    static let zero = MTLSize(repeating: 0)

    static func == (lhs: MTLSize, rhs: MTLSize) -> Bool {
        lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.depth == rhs.depth
    }

    static func != (lhs: MTLSize, rhs: MTLSize) -> Bool {
        lhs.width != rhs.width
            || lhs.height != rhs.height
            || lhs.depth != rhs.depth
    }
}
