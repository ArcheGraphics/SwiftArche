//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstCellSpan: Equatable {
    public var min: int4
    public var max: int4

    public init(span: CellSpan) {
        self.min = int4(span.min.x, span.min.y, span.min.z, span.min.w)
        self.max = int4(span.max.x, span.max.y, span.max.z, span.max.w)
    }

    public init(min: int4, max: int4) {
        self.min = min
        self.max = max
    }

    public var level: Int32 { return min.w }
}
