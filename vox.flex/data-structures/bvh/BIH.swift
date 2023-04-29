//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public enum BIH {
    public static func Build(for _: [IBounded], maxDepth _: Int = 10, maxOverlap _: Float = 0.7) -> [BIHNode] {
        []
    }

    public static func HoarePartition(elements _: [IBounded], start _: Int, end _: Int, pivot _: Float,
                                      node _: inout BIHNode, axis _: Int) -> Int
    {
        0
    }

    public static func DistanceToSurface(triangles _: [Triangle],
                                         vertices _: [Vector3],
                                         normals _: [Vector3],
                                         node _: BIHNode,
                                         point _: Vector3) -> Float
    {
        0
    }

    public static func DistanceToSurface(nodes _: [BIHNode],
                                         triangles _: [Triangle],
                                         vertices _: [Vector3],
                                         normals _: [Vector3],
                                         point _: Vector3) -> Float
    {
        0
    }

    public static func DistanceToSurface(nodes _: [BIHNode],
                                         triangles _: [Triangle],
                                         vertices _: [Vector3],
                                         normals _: [Vector3],
                                         node _: BIHNode,
                                         point _: Vector3) -> Float
    {
        0
    }
}
