//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for beveling edges.
public enum Bevel {
    /// Apply a bevel to a set of edges.
    /// - Parameters:
    ///   - mesh: Target mesh.
    ///   - edges: A set of edges to apply bevelling to.
    ///   - amount: A value from 0 (bevel not at all) to 1 (bevel entire face).
    /// - Returns: The new faces created to form the bevel.
    public static func BevelEdges(mesh _: ProBuilderMesh, edges _: Edge, amount _: Float) -> [Face] {
        []
    }

    static let k_BridgeIndexesTri: [Int] = [2, 1, 0]

    static func GetBridgeFaces(vertices _: [Vertex],
                               left _: WingedEdge,
                               right _: WingedEdge,
                               holes _: [Int: [(FaceRebuildData, [Int])]]) -> [FaceRebuildData]
    {
        []
    }

    static func SlideEdge(vertices _: [Vertex], we _: WingedEdge, amount _: Float) {}

    static func GetLeadingEdge(wing _: WingedEdge, common _: Int) -> Edge {
        Edge(0, 0)
    }
}
