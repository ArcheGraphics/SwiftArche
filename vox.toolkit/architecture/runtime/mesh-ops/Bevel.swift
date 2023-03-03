//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Functions for beveling edges.
public class Bevel {
    /// Apply a bevel to a set of edges.
    /// - Parameters:
    ///   - mesh: Target mesh.
    ///   - edges: A set of edges to apply bevelling to.
    ///   - amount: A value from 0 (bevel not at all) to 1 (bevel entire face).
    /// - Returns: The new faces created to form the bevel.
    public static func BevelEdges(mesh: ProBuilderMesh, edges: Edge, amount: Float) -> [Face] {
        []
    }

    static let k_BridgeIndexesTri: [Int] = [2, 1, 0]

    static func GetBridgeFaces(vertices: [Vertex],
                               left: WingedEdge,
                               right: WingedEdge,
                               holes: [Int: [(FaceRebuildData, [Int])]]) -> [FaceRebuildData] {
        []
    }

    static func SlideEdge(vertices: [Vertex], we: WingedEdge, amount: Float) {

    }

    static func GetLeadingEdge(wing: WingedEdge, common: Int) -> Edge {
        Edge(0, 0)
    }
}
