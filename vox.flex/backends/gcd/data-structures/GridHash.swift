//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public enum GridHash {
    public static let cellOffsets3D: [int3] = [
        int3(1, 0, 0),
        int3(0, 1, 0),
        int3(1, 1, 0),
        int3(0, 0, 1),
        int3(1, 0, 1),
        int3(0, 1, 1),
        int3(1, 1, 1),
        int3(-1, 1, 0),
        int3(-1, -1, 1),
        int3(0, -1, 1),
        int3(1, -1, 1),
        int3(-1, 0, 1),
        int3(-1, 1, 1),
    ]

    public static let cellOffsets: [int3] = [
        int3(0, 0, 0),
        int3(-1, 0, 0),
        int3(0, -1, 0),
        int3(0, 0, -1),
        int3(1, 0, 0),
        int3(0, 1, 0),
        int3(0, 0, 1),
    ]

    public static let cell2DOffsets: [int2] = [
        int2(0, 0),
        int2(-1, 0),
        int2(0, -1),
        int2(1, 0),
        int2(0, 1),
    ]

    public static func Hash(v: float3, cellSize: Float) -> Int32 {
        return Hash(grid: Quantize(v: v, cellSize: cellSize))
    }

    public static func Quantize(v: float3, cellSize: Float) -> int3 {
        return int3(floor(v / cellSize))
    }

    public static func Hash(v: float2, cellSize: Float) -> Int32 {
        return Hash(grid: Quantize(v: v, cellSize: cellSize))
    }

    public static func Quantize(v: float2, cellSize: Float) -> int2 {
        return int2(floor(v / cellSize))
    }

    public static func Hash(grid: int3) -> Int32 {
        // Simple int3 hash based on a pseudo mix of :
        // 1) https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
        // 2) https://en.wikipedia.org/wiki/Jenkins_hash_function
        var hash = grid.x
        hash = (hash * 397) ^ grid.y
        hash = (hash * 397) ^ grid.z
        hash += hash << 3
        hash ^= hash >> 11
        hash += hash << 15
        return hash
    }

    public static func Hash(grid: int2) -> Int32 {
        // Simple int3 hash based on a pseudo mix of :
        // 1) https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
        // 2) https://en.wikipedia.org/wiki/Jenkins_hash_function
        var hash = grid.x
        hash = (hash * 397) ^ grid.y
        hash += hash << 3
        hash ^= hash >> 11
        hash += hash << 15
        return hash
    }

    public static func Hash(hash: UInt64, key: UInt64) -> UInt64 {
        let m: UInt64 = 0xC6A4_A793_5BD1_E995
        let r = 47

        var h = hash
        var k = key

        k *= m
        k ^= k >> r
        k *= m

        h ^= k
        h *= m

        h ^= h >> r
        h *= m
        h ^= h >> r

        return h
    }
}
