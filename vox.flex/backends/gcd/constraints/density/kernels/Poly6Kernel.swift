//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct Poly6Kernel {
    public var norm: Float
    public var norm2D: Bool

    public init(norm2D: Bool) {
        self.norm2D = norm2D
        if norm2D {
            norm = 4.0 / Float.pi
        } else {
            norm = 315.0 / (64.0 * Float.pi)
        }
    }

    public func W(r: Float, h: Float) -> Float {
        let h2 = h * h
        let h4 = h2 * h2
        let h8 = h4 * h4

        let rl = min(r, h)
        let hr = h2 - rl * rl

        if norm2D {
            return norm / h8 * hr * hr * hr
        }
        return norm / (h8 * h) * hr * hr * hr
    }
}
