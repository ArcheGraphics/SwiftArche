//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

class SelectPathFaces {
    static var s_cachedPredecessors: [Int] = []
    static var s_cachedStart: Int = 0
    static var s_cachedMesh: ProBuilderMesh?
    static var s_cachedFacesCount: Int = 0
    static var s_cachedWings: [WingedEdge] = []
    static var s_cachedFacesIndex: Dictionary<Face, Int> = [:]

    /// Calculates the indexes of all faces in the shortest path between start and end
    /// - Parameters:
    ///   - mesh: The index of the starting face
    ///   - start: The index of the ending face
    ///   - end: The mesh of the object
    /// - Returns: The indexes of all faces
    public static func GetPath(mesh: ProBuilderMesh, start: Int, end: Int) -> [Int] {
        []
    }

    /// Builds a list of predecessors from a given face index to all other faces
    /// Uses the Djikstra pathfinding algorithm
    /// - Parameters:
    ///   - mesh: The mesh of the object
    ///   - start: The index of the starting face
    /// - Returns: A list of predecessors from a face index to all other faces
    static func Dijkstra(mesh: ProBuilderMesh, start: Int) -> [Int] {
        []
    }

    static func GetWeight(face1: Int, face2: Int, mesh: ProBuilderMesh) -> Float {
        0
    }


    static func GetMinimalPath(predecessors: [Int], start: Int, end: Int) -> [Int] {
        []
    }
}
