//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct SimplexCounts {
    public var pointCount: Int
    public var edgeCount: Int
    public var triangleCount: Int

    public var simplexCount: Int { return pointCount + edgeCount + triangleCount }

    public init(pointCount: Int, edgeCount: Int, triangleCount: Int) {
        self.pointCount = pointCount
        self.edgeCount = edgeCount
        self.triangleCount = triangleCount
    }

    public func GetSimplexStartAndSize(at index: Int, size: inout Int) -> Int {
        if index < pointCount {
            size = 1
            return index
        } else if index < pointCount + edgeCount {
            size = 2
            return pointCount + (index - pointCount) * 2
        } else if index < simplexCount {
            size = 3
            let triStart = pointCount + edgeCount * 2
            return triStart + (index - pointCount - edgeCount) * 3
        }
        size = 0
        return 0
    }
}
