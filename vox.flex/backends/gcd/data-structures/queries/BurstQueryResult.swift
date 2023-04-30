//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstQueryResult {
    public var simplexBary: float4
    public var queryPoint: float4
    public var normal: float4
    public var distance: Float
    public var simplexIndex: Int
    public var queryIndex: Int
}
