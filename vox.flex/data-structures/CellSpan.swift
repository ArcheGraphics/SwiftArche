//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct CellSpan {
    public var min: VInt4
    public var max: VInt4

    public init(min: VInt4, max: VInt4) {
        self.min = min
        self.max = max
    }
}
