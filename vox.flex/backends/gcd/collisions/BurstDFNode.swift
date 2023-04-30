//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstDFNode {
    public var distancesA: float4
    public var distancesB: float4
    public var center: float4
    public var firstChild: Int

    public func SampleWithGradient(at _: float4) -> float4 {
        float4()
    }

    public func GetNormalizedPos(at _: float4) -> float4 {
        float4()
    }

    public func GetOctant(at _: float4) -> Int {
        0
    }
}
