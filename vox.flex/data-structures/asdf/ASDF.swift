//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ASDF {
    static let corners: [Vector4] = [
        Vector4(-1, -1, -1, -1),
        Vector4(-1, -1, 1, -1),
        Vector4(-1, 1, -1, -1),
        Vector4(-1, 1, 1, -1),

        Vector4(1, -1, -1, -1),
        Vector4(1, -1, 1, -1),
        Vector4(1, 1, -1, -1),
        Vector4(1, 1, 1, -1),
    ]

    static let samples: [Vector4] = [
        Vector4(0, 0, 0, 0),
        Vector4(1, 0, 0, 0),
        Vector4(-1, 0, 0, 0),
        Vector4(0, 1, 0, 0),
        Vector4(0, -1, 0, 0),
        Vector4(0, 0, 1, 0),
        Vector4(0, 0, -1, 0),

        Vector4(0, -1, -1, 0),
        Vector4(0, -1, 1, 0),
        Vector4(0, 1, -1, 0),
        Vector4(0, 1, 1, 0),

        Vector4(-1, 0, -1, 0),
        Vector4(-1, 0, 1, 0),
        Vector4(1, 0, -1, 0),
        Vector4(1, 0, 1, 0),

        Vector4(-1, -1, 0, 0),
        Vector4(-1, 1, 0, 0),
        Vector4(1, -1, 0, 0),
        Vector4(1, 1, 0, 0),
    ]

    let sqrt3: Float = 1.73205

    public static func Build(maxError _: Float, maxDepth _: Int,
                             vertexPositions _: [Vector3], triangleIndices _: [Int],
                             nodes _: [DFNode], yieldAfterNodeCount _: Int = 32) {}

    public static func Sample(nodes _: [DFNode], position _: Vector3) -> Float {
        0
    }
}
