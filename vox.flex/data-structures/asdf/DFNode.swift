//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct DFNode {
    public var distancesA: Vector4
    public var distancesB: Vector4
    public var center: Vector4
    public var firstChild: Int

    public init(center: Vector4) {
        distancesA = Vector4()
        distancesB = Vector4()
        self.center = center
        firstChild = -1
    }

    public func Sample(at position: Vector3) -> Float {
        let nPos = GetNormalizedPos(at: position)

        // trilinear interpolation: interpolate along x axis
        let x = distancesA + (distancesB - distancesA) * nPos.x

        // interpolate along y axis
        let y0 = x.x + (x.z - x.x) * nPos.y
        let y1 = x.y + (x.w - x.y) * nPos.y

        // interpolate along z axis.
        return y0 + (y1 - y0) * nPos.z
    }

    public func GetNormalizedPos(at position: Vector3) -> Vector3 {
        let size = center.z * 2
        return Vector3(
            (position.x - (center.x - center.w)) / size,
            (position.y - (center.y - center.w)) / size,
            (position.z - (center.z - center.w)) / size
        )
    }

    public func GetOctant(at position: Vector3) -> Int {
        var index = 0
        if position.x > center.x { index |= 4 }
        if position.y > center.y { index |= 2 }
        if position.z > center.z { index |= 1 }
        return index
    }
}
