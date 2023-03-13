//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// A winged-edge data structure holds references to an edge, the previous and next edge in it's triangle, it's connected face, and the opposite edge (common).
/// ```
/// .       /   (face)    /
/// . prev /             / next
/// .     /    edge     /
/// .    /_ _ _ _ _ _ _/
/// .    |- - - - - - -|
/// .    |  opposite   |
/// .    |             |
/// .    |             |
/// .    |             |
/// ```
public final class WingedEdge {
    static let k_OppositeEdgeDictionary: [Edge: WingedEdge] = [:]

    /// The local and shared edge that this edge belongs to.
    public private(set) var edge: EdgeLookup!

    /// The connected face that this wing belongs to.
    public private(set) var face: Face!

    /// The WingedEdge that is connected to the edge.y vertex.
    public private(set) var next: WingedEdge!

    /// The WingedEdge that is connected to the edge.x vertex.
    public private(set) var previous: WingedEdge!

    /// The WingedEdge that is on the opposite side of this edge.
    public private(set) var opposite: WingedEdge!

    init() {
    }

    /// Equality comparision tests for local edge equality, disregarding other values.
    /// - Parameter other: The WingedEdge to compare against.
    /// - Returns: True if the local edges are equal, false if not.
    public func Equals(other: WingedEdge) -> Bool {
        false
    }

    /// How many edges are in this sequence.
    /// - Returns: The number of WingedEdges that are connected by walking the @"UnityEngine.ProBuilder.WingedEdge.next" property.
    public func Count() -> Int {
        0
    }

    /// Given two adjacent triangle wings, attempt to create a single quad.
    internal static func MakeQuad(left: WingedEdge, right: WingedEdge) -> [Int] {
        []
    }

    /// Return the @"UnityEngine.ProBuilder.WingedEdge.previous" or @"UnityEngine.ProBuilder.WingedEdge.next" WingedEdge if it contains the passed common (shared) index.
    /// - Parameter common: The common index to search next and previous for.
    /// - Returns: The next or previous WingedEdge that contains common, or null if not found.
    public func GetAdjacentEdgeWithCommonIndex(common: Int) -> WingedEdge? {
        nil

    }

    /// Order a face's edges in sequence.
    /// The first edge is used as a starting point.
    /// - Parameter face: The source face.
    /// - Returns: A new set of edges where each edge y value matches the next edge x.
    public static func SortEdgesByAdjacency(face: Face) -> [Edge] {
        []
    }

    /// Sort edges list by adjacency, such that each edge's common y value matches the next edge's common x.
    /// - Parameter edges: The edges to sort in-place.
    public static func SortEdgesByAdjacency(edges: [Edge]) {
    }

    /// Get a dictionary of common indexes and all WingedEdge values touching the index.
    /// - Parameter wings: The wings to search for spokes.
    /// - Returns: A dictionary where each key is a common index with a list of each winged edge touching it.
    public static func GetSpokes(wings: [WingedEdge]) -> [Int: [WingedEdge]] {
        [:]
    }

    /// Given a set of winged edges and list of common indexes, attempt to create a complete path of indexes where each is connected by edge.
    /// May be clockwise or counter-clockwise ordered, or null if no path is found.
    /// - Parameters:
    ///   - wings: The wings to be sorted.
    ///   - common: The common indexes to be sorted.
    internal static func SortCommonIndexesByAdjacency(wings: [WingedEdge], common: Set<Int>) -> [Int] {
        []
    }

    /// Create a new list of WingedEdge values for a ProBuilder mesh.
    /// - Parameters:
    ///   - mesh: The mesh from which faces will read.
    ///   - oneWingPerFace: Optionally restrict the list to only include one WingedEdge per-face.
    /// - Returns: A new list of WingedEdge values gathered from @"UnityEngine.ProBuilder.ProBuilderMesh.faces".
    public static func GetWingedEdges(mesh: ProBuilderMesh, oneWingPerFace: Bool = false) -> [WingedEdge] {
        []
    }

    /// Create a new list of WingedEdge values for a ProBuilder mesh.
    /// - Parameters:
    ///   - mesh: Target ProBuilderMesh.
    ///   - faces: Which faces to include in the WingedEdge list.
    ///   - oneWingPerFace: If `oneWingPerFace` is true the returned list will contain a single winged edge per-face (but still point to all edges).
    /// - Returns: A new list of WingedEdge values gathered from faces.
    public static func GetWingedEdges(mesh: ProBuilderMesh, faces: [Face], oneWingPerFace: Bool = false) -> [WingedEdge] {
        []
    }
}

extension WingedEdge: Hashable {
    public func hash(into hasher: inout Hasher) {

    }

    public static func ==(lhs: WingedEdge, rhs: WingedEdge) -> Bool {
        lhs.Equals(other: rhs)
    }
}

extension WingedEdge: CustomStringConvertible {
    public var description: String {
        ""
    }
}
