//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstMath {
    public let epsilon: Float = 0.0000001
    public let zero: Float = 0
    public let one: Float = 1
    public static let golden: Float = (sqrt(5.0) + 1.0) / 2.0

    public struct CachedTri {
        public var vertex: float4
        public var edge0: float4
        public var edge1: float4
        public var data: float4

        public mutating func Cache(v1: float4,
                                   v2: float4,
                                   v3: float4)
        {
            vertex = v1
            edge0 = v2 - v1
            edge1 = v3 - v1
            data = float4.zero
            data[0] = simd_dot(edge0, edge0)
            data[1] = simd_dot(edge0, edge1)
            data[2] = simd_dot(edge1, edge1)
            data[3] = data[0] * data[2] - data[1] * data[1]
        }
    }
}
