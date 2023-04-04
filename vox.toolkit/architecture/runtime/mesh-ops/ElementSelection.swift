//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public enum ElementSelection {
    static let k_MaxHoleIterations = 2048

    /// Fills a list of <![CDATA[Face]]> where each face is connected to the passed edge in the ProBuilderMesh.
    /// - Parameters:
    ///   - mesh: the ProBuilder mesh to consider
    ///   - edge: the edge ton consider
    ///   - neighborFaces: The list filled by the method
    public static func GetNeighborFaces(mesh _: ProBuilderMesh, edge _: Edge, neighborFaces _: [Face]) {}

    /// Returns a list of <![CDATA[SimpleTuple<Face, Edge>]]> where each face is connected to the passed edge.
    internal static func GetNeighborFaces(mesh _: ProBuilderMesh, edge _: Edge) -> [(Face, Edge)] {
        []
    }

    /// Gets all faces connected to each index taking into account shared vertices.
    internal static func GetNeighborFaces(mesh _: ProBuilderMesh, indexes _: [Int]) -> [Face] {
        []
    }

    /// Returns a unique array of Edges connected to the passed vertex indexes.
    internal static func GetConnectedEdges(mesh _: ProBuilderMesh, indexes _: [Int]) -> [Edge] {
        []
    }

    /// Get all edges that are on the perimeter of this face group selection.
    /// - Parameters:
    ///   - mesh: mesh
    ///   - faces: The faces to search for perimeter edge path.
    /// - Returns: A list of the edges on the perimeter of each group of adjacent faces.
    public static func GetPerimeterEdges<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T) -> [Edge] {
        []
    }

    /// Returns the indexes of perimeter edges in a given element group.
    internal static func GetPerimeterEdges(mesh _: ProBuilderMesh, edges _: [Edge]) -> [Int] {
        []
    }

    /// Returns an array of faces where each face has at least one non-shared edge.
    internal static func GetPerimeterFaces<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T) -> [Face] {
        []
    }

    internal static func GetPerimeterVertices(mesh _: ProBuilderMesh, indexes _: [Int], universal_edges_all _: [Edge]) -> [Int] {
        []
    }

    static func EdgeRingNext(edge _: WingedEdge) -> WingedEdge {
        WingedEdge()
    }

    /// Iterates through face edges and builds a list using the opposite edge.
    internal static func GetEdgeRing<T: Sequence<Edge>>(pb _: ProBuilderMesh, edges _: T) -> [Edge] {
        []
    }

    /// Iterates through face edges and builds a list using the opposite edge, iteratively.
    /// - Parameters:
    ///   - pb: The probuilder mesh
    ///   - edges: The edges already selected
    /// - Returns: The new selected edges
    internal static func GetEdgeRingIterative<T: Sequence<Edge>>(pb _: ProBuilderMesh, edges _: T) -> [Edge] {
        []
    }

    /// Attempts to find edges along an Edge loop.
    ///
    /// http://wiki.blender.org/index.php/Doc:2.4/Manual/Modeling/Meshes/Selecting/Edges says:
    /// First check to see if the selected element connects to only 3 other edges.
    /// If the edge in question has already been added to the list, the selection ends.
    /// Of the 3 edges that connect to the current edge, the ones that share a face with the current edge are eliminated
    /// and the remaining edge is added to the list and is made the current edge.
    internal static func GetEdgeLoop<T: Sequence<Edge>>(mesh _: ProBuilderMesh, edges _: T, loop _: inout [Edge]) -> Bool {
        false
    }

    /// Attempts to find edges along an Edge loop in an iterative way
    ///
    /// Adds two edges to the selection, one at each extremity
    internal static func GetEdgeLoopIterative<T: Sequence<Edge>>(mesh _: ProBuilderMesh, edges _: T, loop _: inout [Edge]) -> Bool {
        false
    }

    static func GetEdgeLoopInternal(start _: WingedEdge, startIndex _: Int, used _: Set<EdgeLookup>) -> Bool {
        false
    }

    static func GetEdgeLoopInternalIterative(start _: WingedEdge, edge _: Edge, used _: Set<EdgeLookup>) {}

    static func NextSpoke(wing _: WingedEdge, pivot _: Int, opp _: Bool) -> WingedEdge {
        WingedEdge()
    }

    /// Return all edges connected to @wing with @sharedIndex as the pivot point. The first entry in the list is always the queried wing.
    internal static func GetSpokes(wing _: WingedEdge, sharedIndex _: Int, allowHoles _: Bool = false) -> [WingedEdge] {
        []
    }

    /// Grow faces to include any face touching the perimeter edges.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to grow out from.
    ///   - maxAngleDiff: If provided, adjacent faces must have a normal that is within maxAngleDiff (in degrees) difference of the perimeter face.
    /// - Returns: The original faces selection, plus any new faces added as a result the grow operation.
    public static func GrowSelection<T: Sequence<Face>>(mesh _: ProBuilderMesh, faces _: T, maxAngleDiff _: Float = -1) -> Set<Face> {
        Set()
    }

    internal static func Flood(wing _: WingedEdge, selection _: Set<Face>) {}

    internal static func Flood(pb _: ProBuilderMesh, wing _: WingedEdge, wingNrm _: Vector3, maxAngle _: Float, selection _: Set<Face>) {}

    /// Recursively add all faces touching any of the selected faces.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The starting faces.
    ///   - maxAngleDiff: Faces must have a normal that is within maxAngleDiff (in degrees) difference of the perimeter face to be added to the collection.
    /// - Returns: A collection of faces that are connected by shared edges to the original faces.
    public static func FloodSelection(mesh _: ProBuilderMesh, faces _: [Face], maxAngleDiff _: Float) -> Set<Face> {
        Set()
    }

    /// Fetch a face loop.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to scan for loops.
    ///   - ring: Toggles between loop and ring. Ring and loop are arbritary with faces, so this parameter just toggles between which gets scanned first.
    /// - Returns: A collection of faces gathered by extending a ring or loop,
    public static func GetFaceLoop(mesh _: ProBuilderMesh, faces _: [Face], ring _: Bool = false) -> Set<Face> {
        Set()
    }

    /// Get both a face ring and loop from the selected faces.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to scan for ring and loops.
    /// - Returns: A collection of faces gathered by extending in a ring and loop,
    public static func GetFaceRingAndLoop(mesh _: ProBuilderMesh, faces _: [Face]) -> Set<Face> {
        Set()
    }

    /// Get a face loop or ring from a set of winged edges.
    static func GetFaceLoop(wings _: [WingedEdge], face _: Face, ring _: Bool) -> Set<Face> {
        Set()
    }

    /// Find any holes touching one of the passed vertex indexes.
    internal static func FindHoles<T: Sequence<Int>>(mesh _: ProBuilderMesh, indexes _: T) -> [[Edge]] {
        [[]]
    }

    /// Find any holes touching one of the passed common indexes.
    internal static func FindHoles(wings _: [WingedEdge], common _: Set<Int>) -> [[WingedEdge]] {
        [[]]
    }

    static func FindNextEdgeInHole(wing _: WingedEdge, common _: Int) -> WingedEdge {
        WingedEdge()
    }
}
