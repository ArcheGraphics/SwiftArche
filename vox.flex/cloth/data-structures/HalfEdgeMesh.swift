//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class HalfEdgeMesh {
    public var inputMesh: ModelMesh?
    public var scale = Vector3.one

    private var _area: Float = 0
    private var _volume: Float = 0

    public struct HalfEdge {
        public var index: Int
        public var indexInFace: Int
        public var face: Int
        public var nextHalfEdge: Int
        public var pair: Int
        public var endVertex: Int
    }

    public struct Vertex {
        public var index: Int
        public var halfEdge: Int
        public var position: Vector3
    }

    public struct Face {
        public var index: Int
        public var halfEdge: Int
    }

    public var containsData = false
    public var vertices: [Vertex] = []
    public var halfEdges: [HalfEdge] = []
    public var borderEdges: [HalfEdge] = []
    public var faces: [Face] = []
    public var restNormals: [Vector3] = []
    public var restOrientations: [Quaternion] = []
    public var rawToWelded: [Int] = []

    public init() {}

    public init(halfEdge _: HalfEdgeMesh) {}

    public func Generate() {}

    private func CalculateRestNormals() {}

    private func CalculateRestOrientations() {}

    public func SwapVertices(index1 _: Int, index2 _: Int) {}

    public func GetHalfEdgeStartVertex(edge _: HalfEdge) -> Int { 0 }

    public func GetFaceArea(face _: Face) -> Float { 0 }

    public func GetNeighbourVerticesEnumerator(vertex _: Vertex) {}

    public func GetNeighbourEdgesEnumerator(vertex _: Vertex) {}

    public func GetNeighbourFacesEnumerator(vertex _: Vertex) {}

    /// Calculates and returns a list of all edges (note: not half-edges, but regular edges) in the mesh. Each edge is represented as the index of
    /// the first half-edge in the list that is part of the edge.
    /// This is O(2N) in both time and space, with N = number of edges.
    public func GetEdgeList() -> [Int] {
        []
    }

    /// Returns true if the edge has been split in a vertex split operation. (as a result of tearing)
    public func IsSplit(halfEdgeIndex _: Int) -> Bool {
        false
    }
}
