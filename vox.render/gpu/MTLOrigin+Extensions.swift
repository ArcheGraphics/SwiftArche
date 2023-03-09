//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public extension MTLOrigin {
    init(repeating value: Int) {
        self.init(x: value,
                y: value,
                z: value)
    }

    func clamped(to size: MTLSize) -> MTLOrigin {
        MTLOrigin(x: min(max(x, 0), size.width),
                y: min(max(y, 0), size.height),
                z: min(max(z, 0), size.depth))
    }

    static let zero = MTLOrigin(repeating: 0)

    static func ==(lhs: MTLOrigin, rhs: MTLOrigin) -> Bool {
        lhs.x == rhs.x
                && lhs.y == rhs.y
                && lhs.z == rhs.z
    }

    static func !=(lhs: MTLOrigin, rhs: MTLOrigin) -> Bool {
        lhs.x != rhs.x
                || lhs.y != rhs.y
                || lhs.z != rhs.z
    }
}
