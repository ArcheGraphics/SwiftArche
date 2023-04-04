//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// An edge connecting two vertices. May point to an index in the vertices or the sharedIndexes array (local / common in ProBuilder terminology).
public struct Edge {
    /// An index corresponding to a mesh vertex array.
    public var a: Int

    /// An index corresponding to a mesh vertex array.
    public var b: Int

    /// An empty edge is defined as -1, -1.
    public static let Empty = Edge(-1, -1)

    /// Create a new edge from two vertex indexes.
    /// - Parameters:
    ///   - a: An index corresponding to a mesh vertex array.
    ///   - b: An index corresponding to a mesh vertex array.
    public init(_ a: Int, _ b: Int) {
        self.a = a
        self.b = b
    }

    /// Test if this edge points to valid vertex indexes.
    /// - Returns: True if x and y are both greater than -1.
    public func IsValid() -> Bool {
        a > -1 && b > -1 && a != b
    }

    public func Equals(other: Edge) -> Bool {
        (a == other.a && b == other.b) || (a == other.b && b == other.a)
    }
}

public extension Edge {
    static func + (a: Edge, b: Edge) -> Edge {
        Edge(a.a + b.a, a.b + b.b)
    }

    static func - (a: Edge, b: Edge) -> Edge {
        Edge(a.a - b.a, a.b - b.b)
    }

    static func + (a: Edge, b: Int) -> Edge {
        Edge(a.a + b, a.b + b)
    }

    static func - (a: Edge, b: Int) -> Edge {
        Edge(a.a - b, a.b - b)
    }

    static func == (a: Edge, b: Edge) -> Bool {
        a.Equals(other: b)
    }

    /// Add two edges index values.
    /// {0, 1} + {4, 5} = {5, 6}
    /// - Parameters:
    ///   - a: Left edge parameter.
    ///   - b: Right edge parameter.
    /// - Returns: The sum of a + b.
    static func Add(_ a: Edge, _ b: Edge) -> Edge {
        a + b
    }

    /// Subtract edge b from a.
    /// Subtract( {7, 10}, {4, 5} ) = {3, 5}
    /// - Parameters:
    ///   - a: The edge to subtract from.
    ///   - b: The value to subtract.
    /// - Returns: The sum of a - b.
    static func Subtract(_ a: Edge, _ b: Edge) -> Edge {
        a - b
    }

    /// Compares edges and takes shared triangles into account.
    /// - Remark:
    /// Generally you just pass ProBuilderMesh.sharedIndexes.ToDictionary() to lookup, but it's more efficient to do it once and reuse that dictionary if possible.
    /// - Parameters:
    ///   - other: The edge to compare against.
    ///   - lookup: A common vertex indexes lookup dictionary. See pb_IntArray for more information.
    /// - Returns: True if edges are perceptually equal (that is, they point to the same common indexes).
    func Equals(other: Edge, lookup: [Int: Int] = [:]) -> Bool {
        if lookup.isEmpty {
            return Equals(other: other)
        }
        let x0 = lookup[a], y0 = lookup[b], x1 = lookup[other.a], y1 = lookup[other.b]
        return (x0 == x1 && y0 == y1) || (x0 == y1 && y0 == x1)
    }

    /// Does this edge contain an index?
    /// - Parameter index: The index to compare against x and y.
    /// - Returns: True if x or y is equal to a. False if not.
    func Contains(index: Int) -> Bool {
        a == index || b == index
    }

    /// Does this edge have any matching index to edge b?
    /// - Parameter other: The edge to compare against.
    /// - Returns: True if x or y matches either b.x or b.y.
    func Contains(other: Edge) -> Bool {
        a == other.a || b == other.a || a == other.b || b == other.a
    }

    internal func Contains(index: Int, lookup: [Int: Int]) -> Bool {
        let common = lookup[index]
        return lookup[a] == common || lookup[b] == common
    }

    internal static func GetIndices(edges: [Edge], indices: inout [Int]) {
        indices = []

        for edge in edges {
            indices.append(edge.a)
            indices.append(edge.b)
        }
    }
}

extension Edge: Hashable {}

extension Edge: CustomStringConvertible {
    public var description: String {
        "[\(a), \(b)]"
    }
}
