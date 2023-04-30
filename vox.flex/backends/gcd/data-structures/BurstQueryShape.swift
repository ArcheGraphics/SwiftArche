//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct BurstQueryShape {
    public var center: float4
    public var size: float4
    public var type: QueryShape.QueryType
    public var contactOffset: Float
    public var distance: Float
    public var filter: Int
}
