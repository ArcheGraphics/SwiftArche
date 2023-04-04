//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// An edge composed of both the local index and common index.
///
/// This is useful when comparing vertex indexes that are coincident.
/// Coincident vertices are defined as vertices that are share the same coordinate space,
/// but are separate values in the vertex array. ProBuilder tracks these coincident values in the @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes" array.
/// A "common" (also called "shared") index is the index of a vertex in the sharedIndexes array.
public struct EdgeLookup {
    var m_Local: Edge
    var m_Common: Edge

    /// Local edges point to an index in the vertices array.
    public var local: Edge {
        get {
            m_Local
        }
        set {
            m_Local = newValue
        }
    }

    /// Commmon edges point to the vertex index in the sharedIndexes array.
    public var common: Edge {
        get {
            m_Common
        }
        set {
            m_Common = newValue
        }
    }

    /// Create an edge lookup from a common and local edge.
    /// - Parameters:
    ///   - common: An edge composed of common indexes (corresponds to @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes").
    ///   - local: An edge composed of vertex indexes (corresponds to mesh vertex arrays).
    public init(common: Edge, local: Edge) {
        m_Common = common
        m_Local = local
    }

    /// Create an edge lookup from common and local edges.
    /// - Parameters:
    ///   - cx: Common edge x.
    ///   - cy: Common edge y.
    ///   - x: Local edge x.
    ///   - y: Local edge y.
    public init(cx: Int, cy: Int, x: Int, y: Int) {
        m_Common = Edge(cx, cy)
        m_Local = Edge(x, y)
    }

    /// Compares each EdgeLookup common edge (does not take into account local edge differences).
    /// - Parameter other: The EdgeLookup to compare against.
    /// - Returns: True if the common edges are equal, false if not.
    public func Equals(other: EdgeLookup) -> Bool {
        return other.common.Equals(other: common)
    }
}

public extension EdgeLookup {
    /// Create a list of EdgeLookup edges from a set of local edges and a sharedIndexes dictionary.
    /// - Parameters:
    ///   - edges: A collection of local edges.
    ///   - lookup: A shared index lookup dictionary (see ProBuilderMesh.sharedIndexes).
    /// - Returns: A set of EdgeLookup edges.
    static func GetEdgeLookup(edges _: [Edge], lookup _: [Int: Int]) -> [EdgeLookup] {
        []
    }

    /// Create a hashset of edge lookup values from a collection of local edges and a shared indexes lookup.
    /// - Parameters:
    ///   - edges: A collection of local edges.
    ///   - lookup: A shared index lookup dictionary (see ProBuilderMesh.sharedIndexes).
    /// - Returns: A HashSet of EdgeLookup edges. EdgeLookup values are compared by their common property only - local edges are not compared.
    static func GetEdgeLookupHashSet(edges _: [Edge], lookup _: [Int: Int]) -> Set<EdgeLookup> {
        Set()
    }
}

extension EdgeLookup: Hashable {}

extension EdgeLookup: CustomStringConvertible {
    public var description: String {
        "Common: (\(common.a), \(common.b)), local: (\(local.a), \(local.b)"
    }
}
