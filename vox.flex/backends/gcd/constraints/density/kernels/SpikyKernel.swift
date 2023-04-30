//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct SpikyKernel {
    public var norm: Float
    public var norm2D: Bool

    public init(norm2D: Bool) {
        self.norm2D = norm2D
        if norm2D {
            norm = -30.0 / Float.pi
        } else {
            norm = -45.0 / Float.pi
        }
    }

    public func W(r: Float, h: Float) -> Float {
        let h2 = h * h
        let h4 = h2 * h2

        let rl = min(r, h)
        let hr = h - rl

        if norm2D {
            return norm / (h4 * h) * hr * hr
        }
        return norm / (h4 * h2) * hr * hr
    }
}
