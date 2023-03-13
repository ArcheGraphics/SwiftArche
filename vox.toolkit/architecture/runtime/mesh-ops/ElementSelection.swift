//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

public class ElementSelection {
    static let k_MaxHoleIterations = 2048
    
    /// Fills a list of <![CDATA[Face]]> where each face is connected to the passed edge in the ProBuilderMesh.
    /// - Parameters:
    ///   - mesh: the ProBuilder mesh to consider
    ///   - edge: the edge ton consider
    ///   - neighborFaces: The list filled by the method
    public static func GetNeighborFaces(mesh: ProBuilderMesh, edge: Edge, neighborFaces: [Face]) {
    }

    /// Returns a list of <![CDATA[SimpleTuple<Face, Edge>]]> where each face is connected to the passed edge.
    internal static func GetNeighborFaces(mesh: ProBuilderMesh, edge: Edge) -> [(Face, Edge)] {
        []
    }

    /// Gets all faces connected to each index taking into account shared vertices.
    internal static func GetNeighborFaces(mesh: ProBuilderMesh, indexes: [Int]) -> [Face] {
        []
    }

    /// Returns a unique array of Edges connected to the passed vertex indexes.
    internal static func GetConnectedEdges(mesh: ProBuilderMesh, indexes: [Int]) -> [Edge] {
        []
    }

    /// Get all edges that are on the perimeter of this face group selection.
    /// - Parameters:
    ///   - mesh: mesh
    ///   - faces: The faces to search for perimeter edge path.
    /// - Returns: A list of the edges on the perimeter of each group of adjacent faces.
    public static func GetPerimeterEdges<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) -> [Edge] {
        []
    }

    /// Returns the indexes of perimeter edges in a given element group.
    internal static func GetPerimeterEdges(mesh: ProBuilderMesh, edges: [Edge]) -> [Int] {
        []
    }

    /// Returns an array of faces where each face has at least one non-shared edge.
    internal static func GetPerimeterFaces<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) -> [Face] {
        []
    }

    internal static func GetPerimeterVertices(mesh: ProBuilderMesh, indexes: [Int], universal_edges_all: [Edge]) -> [Int] {
        []
    }


    static func EdgeRingNext(edge: WingedEdge) -> WingedEdge {
        WingedEdge()
    }


    /// Iterates through face edges and builds a list using the opposite edge.
    internal static func GetEdgeRing<T: Sequence<Edge>>(pb: ProBuilderMesh, edges: T) -> [Edge] {
        []
    }

    /// Iterates through face edges and builds a list using the opposite edge, iteratively.
    /// - Parameters:
    ///   - pb: The probuilder mesh
    ///   - edges: The edges already selected
    /// - Returns: The new selected edges
    internal static func GetEdgeRingIterative<T: Sequence<Edge>>(pb: ProBuilderMesh, edges: T) -> [Edge] {
        []
    }

    /// Attempts to find edges along an Edge loop.
    ///
    /// http://wiki.blender.org/index.php/Doc:2.4/Manual/Modeling/Meshes/Selecting/Edges says:
    /// First check to see if the selected element connects to only 3 other edges.
    /// If the edge in question has already been added to the list, the selection ends.
    /// Of the 3 edges that connect to the current edge, the ones that share a face with the current edge are eliminated
    /// and the remaining edge is added to the list and is made the current edge.
    internal static func GetEdgeLoop<T: Sequence<Edge>>(mesh: ProBuilderMesh, edges: T, loop: inout [Edge]) -> Bool {
        false
    }

    /// Attempts to find edges along an Edge loop in an iterative way
    ///
    /// Adds two edges to the selection, one at each extremity
    internal static func GetEdgeLoopIterative<T: Sequence<Edge>>(mesh: ProBuilderMesh, edges: T, loop: inout [Edge]) -> Bool {
        false
    }

    static func GetEdgeLoopInternal(start: WingedEdge, startIndex: Int, used: Set<EdgeLookup>) -> Bool {
        false
    }

    static func GetEdgeLoopInternalIterative(start: WingedEdge, edge: Edge, used: Set<EdgeLookup>) {

    }

    static func NextSpoke(wing: WingedEdge, pivot: Int, opp: Bool) -> WingedEdge {
        WingedEdge()
    }

    /// Return all edges connected to @wing with @sharedIndex as the pivot point. The first entry in the list is always the queried wing.
    internal static func GetSpokes(wing: WingedEdge, sharedIndex: Int, allowHoles: Bool = false) -> [WingedEdge] {
        []
    }

    /// Grow faces to include any face touching the perimeter edges.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to grow out from.
    ///   - maxAngleDiff: If provided, adjacent faces must have a normal that is within maxAngleDiff (in degrees) difference of the perimeter face.
    /// - Returns: The original faces selection, plus any new faces added as a result the grow operation.
    public static func GrowSelection<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T, maxAngleDiff: Float = -1) -> Set<Face> {
        Set()
    }

    internal static func Flood(wing: WingedEdge, selection: Set<Face>) {

    }

    internal static func Flood(pb: ProBuilderMesh, wing: WingedEdge, wingNrm: Vector3, maxAngle: Float, selection: Set<Face>) {

    }

    /// Recursively add all faces touching any of the selected faces.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The starting faces.
    ///   - maxAngleDiff: Faces must have a normal that is within maxAngleDiff (in degrees) difference of the perimeter face to be added to the collection.
    /// - Returns: A collection of faces that are connected by shared edges to the original faces.
    public static func FloodSelection(mesh: ProBuilderMesh, faces: [Face], maxAngleDiff: Float) -> Set<Face> {
        Set()
    }

    /// Fetch a face loop.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to scan for loops.
    ///   - ring: Toggles between loop and ring. Ring and loop are arbritary with faces, so this parameter just toggles between which gets scanned first.
    /// - Returns: A collection of faces gathered by extending a ring or loop,
    public static func GetFaceLoop(mesh: ProBuilderMesh, faces: [Face], ring: Bool = false) -> Set<Face> {
        Set()
    }
    
    /// Get both a face ring and loop from the selected faces.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - faces: The faces to scan for ring and loops.
    /// - Returns: A collection of faces gathered by extending in a ring and loop,
    public static func GetFaceRingAndLoop(mesh: ProBuilderMesh, faces: [Face]) -> Set<Face> {
        Set()
    }

    /// Get a face loop or ring from a set of winged edges.
    static func GetFaceLoop(wings: [WingedEdge], face: Face, ring: Bool) -> Set<Face> {
        Set()
    }

    /// Find any holes touching one of the passed vertex indexes.
    internal static func FindHoles<T: Sequence<Int>>(mesh: ProBuilderMesh, indexes: T) -> [[Edge]] {
        [[]]
    }

    /// Find any holes touching one of the passed common indexes.
    internal static func FindHoles(wings: [WingedEdge], common: Set<Int>) -> [[WingedEdge]] {
        [[]]
    }

    static func FindNextEdgeInHole(wing: WingedEdge, common: Int) -> WingedEdge {
        WingedEdge()
    }
}
