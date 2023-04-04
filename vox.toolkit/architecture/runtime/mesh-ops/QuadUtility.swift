//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public enum QuadUtility {
    public static func ToQuads(mesh _: ProBuilderMesh, faces _: [Face], smoothing _: Bool = true) -> [Face] {
        []
    }

    static func GetBestQuadConnection(wing _: WingedEdge, connections _: [EdgeLookup: Float]) -> Face {
        Face()
    }

    /// Get a weighted value for the quality of a quad composed of two triangles. 0 is terrible, 1 is perfect.
    /// normalThreshold will discard any quads where the dot product of their normals is less than the threshold.
    /// @todo Abstract the quad detection to a separate class so it can be applied to pb_Objects.
    static func GetQuadScore(mesh _: ProBuilderMesh, left _: WingedEdge, right _: WingedEdge, normalThreshold _: Float = 0.9) -> Float {
        0
    }
}
