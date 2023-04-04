//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class SelectPathFaces {
    static var s_cachedPredecessors: [Int] = []
    static var s_cachedStart: Int = 0
    static var s_cachedMesh: ProBuilderMesh?
    static var s_cachedFacesCount: Int = 0
    static var s_cachedWings: [WingedEdge] = []
    static var s_cachedFacesIndex: [Face: Int] = [:]

    /// Calculates the indexes of all faces in the shortest path between start and end
    /// - Parameters:
    ///   - mesh: The index of the starting face
    ///   - start: The index of the ending face
    ///   - end: The mesh of the object
    /// - Returns: The indexes of all faces
    public static func GetPath(mesh _: ProBuilderMesh, start _: Int, end _: Int) -> [Int] {
        []
    }

    /// Builds a list of predecessors from a given face index to all other faces
    /// Uses the Djikstra pathfinding algorithm
    /// - Parameters:
    ///   - mesh: The mesh of the object
    ///   - start: The index of the starting face
    /// - Returns: A list of predecessors from a face index to all other faces
    static func Dijkstra(mesh _: ProBuilderMesh, start _: Int) -> [Int] {
        []
    }

    static func GetWeight(face1 _: Int, face2 _: Int, mesh _: ProBuilderMesh) -> Float {
        0
    }

    static func GetMinimalPath(predecessors _: [Int], start _: Int, end _: Int) -> [Int] {
        []
    }
}
