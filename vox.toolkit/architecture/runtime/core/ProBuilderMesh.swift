//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// This component is responsible for storing all the data necessary for editing and compiling UnityEngine.Mesh objects.
public final class ProBuilderMesh: Script {
    /// Max number of UV channels that ProBuilderMesh format supports.
    let k_UVChannelCount = 4

    /// The current mesh format version. This is used to run expensive upgrade functions once in ToMesh().
    internal static let k_MeshFormatVersion = k_MeshFormatVersionAutoUVScaleOffset
    internal static let k_MeshFormatVersionSubmeshMaterialRefactor = 1
    internal static let k_MeshFormatVersionAutoUVScaleOffset = 2

    /// The maximum number of vertices that a ProBuilderMesh can accomodate.
    public static let maxVertexCount = UInt8.max

    // MeshFormatVersion is used to deprecate and upgrade serialized data.
    var m_MeshFormatVersion: Int = 0

    var m_Faces: [Face] = []

    var m_SharedVertices: [SharedVertex] = []

    public struct CacheValidState: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let SharedVertex = CacheValidState(rawValue: 1 << 0)
        public static let SharedTexture = CacheValidState(rawValue: 1 << 1)
    }

    var m_CacheValid: CacheValidState = []

    var m_SharedVertexLookup: Dictionary<Int, Int> = [:]

    var m_SharedTextures: [SharedVertex] = []

    var m_SharedTextureLookup: [Int: Int] = [:]

    var m_Positions: [Vector3] = []

    var m_Textures0: [Vector2] = []

    var m_Textures2: [Vector4] = []

    var m_Textures3: [Vector4] = []

    var m_Tangents: [Vector4] = []

    var m_Normals: [Vector3] = []

    var m_Colors: [Color] = []

    /// If false, ProBuilder will automatically create and scale colliders.
    public var userCollisions: Bool = false

    var m_UnwrapParameters = UnwrapParameters()

    /// UV2 generation parameters.
    public var unwrapParameters: UnwrapParameters {
        get {
            return m_UnwrapParameters
        }
        set {
            m_UnwrapParameters = newValue
        }
    }

    var m_PreserveMeshAssetOnDestroy: Bool = false

    /// If "Meshes are Assets" feature is enabled, this is used to relate pb_Objects to stored meshes.
    internal var assetGuid: String = ""

    var m_Mesh: Mesh?

    var m_MeshRenderer: MeshRenderer?

    /// Simple uint tracking number of time ToMesh() and Refresh() function are called to modify the mesh
    /// Used to check if 2 versions of the ProBuilderMesh are the same or not.
    var m_VersionIndex: UInt8 = 0
    internal var versionIndex: UInt8 {
        m_VersionIndex
    }

    /// In the editor, when you delete a ProBuilderMesh you usually also want to destroy the mesh asset.
    /// However, there are situations you'd want to keep the mesh around, like when stripping probuilder scripts.
    public var preserveMeshAssetOnDestroy: Bool {
        get {
            m_PreserveMeshAssetOnDestroy
        }
        set {
            m_PreserveMeshAssetOnDestroy = newValue
        }
    }

    /// Check if the mesh contains the requested arrays.
    /// - Parameter channels: A flag containing the array types that a ProBuilder mesh stores.
    /// - Returns: True if all arrays in the flag are present, false if not.
    public func HasArrays(channels: MeshArrays) -> Bool {
        false
    }

    internal var facesInternal: [Face] {
        get {
            m_Faces
        }
        set {
            m_Faces = newValue
        }
    }

    /// Meshes are composed of vertices and faces. Faces primarily contain triangles and material information. With these components, ProBuilder will compile a mesh.
    /// A collection of the @"UnityEngine.ProBuilder.Face"'s that make up this mesh.
    public var faces: [Face] {
        get {
            m_Faces
        }
        set {
            m_Faces = newValue
        }
    }

    internal func InvalidateSharedVertexLookup() {
    }

    internal func InvalidateSharedTextureLookup() {
    }

    internal func InvalidateFaces() {
    }

    internal func InvalidateCaches() {
    }

    internal var sharedVerticesInternal: [SharedVertex] {
        get {
            []
        }
        set {

        }
    }

    /// ProBuilder makes the assumption that no @"UnityEngine.ProBuilder.Face" references a vertex used by another.
    /// However, we need a way to associate vertices in the editor for many operations. These vertices are usually
    /// called coincident, or shared vertices. ProBuilder manages these associations with the sharedIndexes array.
    /// Each array contains a list of triangles that point to vertices considered to be coincident. When ProBuilder
    /// compiles a UnityEngine.Mesh from the ProBuilderMesh, these vertices will be condensed to a single vertex
    /// where possible.
    /// The shared (or common) index array for this mesh.
    public var sharedVertices: [SharedVertex] {
        get {
            []
        }
        set {

        }
    }

    internal var sharedVertexLookup: [Int: Int] {
        get {
            [:]
        }
        set {

        }
    }

    /// <summary>
    /// Set the sharedIndexes array for this mesh with a lookup dictionary.
    /// </summary>
    /// <param name="indexes">
    /// The new sharedIndexes array.
    /// </param>
    /// <seealso cref="sharedVertices"/>
    internal func SetSharedVertices(indexes: [(Int, Int)]) {

    }

    internal var sharedTextures: [SharedVertex] {
        get {
            []
        }
        set {
        }
    }

    internal var sharedTextureLookup: [Int: Int] {
        get {
            [:]
        }
        set {
        }
    }

    internal func SetSharedTextures(indexes: [(Int, Int)]) {

    }

    internal var positionsInternal: [Vector3] {
        get {
            []
        }
        set {

        }
    }

    /// The vertex positions that make up this mesh.
    public var positions: [Vector3] {
        get {
            []
        }
        set {

        }
    }

    /// Creates a new array of vertices with values from a @"UnityEngine.ProBuilder.ProBuilderMesh" component.
    /// - Parameter indexes: An optional list of indexes pointing to the mesh attribute indexes to include in the returned Vertex array.
    /// - Returns: An array of vertices.
    public func GetVertices(indexes: [Int]? = nil) -> [Vertex] {
        []
    }

    /// Get a list of vertices from a @"UnityEngine.ProBuilder.ProBuilderMesh" component.
    /// - Parameter vertices: The list that will be filled by the method.
    internal func GetVerticesInList(vertices: [Vertex]) {

    }

    /// Set the vertex element arrays on this mesh.
    /// - Parameters:
    ///   - vertices: The new vertex array.
    ///   - applyMesh: An optional parameter that will apply elements to the MeshFilter.sharedMesh.
    ///   Note that this should only be used when the mesh is in its original state, not optimized
    ///   (meaning it won't affect triangles which can be modified by Optimize).
    public func SetVertices(_ vertices: [Vertex], applyMesh: Bool = false) {

    }

    /// The mesh normals.
    public var normals: [Vector3] {
        get {
            []
        }
    }

    internal var normalsInternal: [Vector3] {
        get {
            return m_Normals
        }
        set {
            m_Normals = newValue
        }
    }

    /// <value>
    /// Get the normals array for this mesh.
    /// </value>
    /// <returns>
    /// Returns the normals for this mesh.
    /// </returns>
    public func GetNormals() -> [Vector3] {
        []
    }

    internal var colorsInternal: [Color] {
        get {
            []
        }
        set {

        }
    }

    /// Vertex colors array for this mesh. When setting, the value must match the length of positions.
    public var colors: [Color] {
        get {
            []
        }
        set {

        }
    }

    /// Get an array of Color values from the mesh.
    /// - Returns: The colors array for this mesh. If mesh does not contain colors, a new array is returned filled with the default value (Color.white).
    public func GetColors() -> [Color] {
        []
    }

    /// Get the user-set tangents array for this mesh. If tangents have not been explicitly set, this value will be null.
    /// - Remark:
    /// To get the generated tangents that are applied to the mesh through Refresh(), use GetTangents().
    public var tangents: [Vector4] {
        get {
            []
        }
        set {

        }
    }

    internal var tangentsInternal: [Vector4] {
        get {
            m_Tangents
        }
        set {
            m_Tangents = newValue
        }
    }

    /// Get the tangents applied to the mesh, or create and cache them if not yet initialized.
    /// - Returns: The tangents applied to the MeshFilter.sharedMesh. If the tangents array length does not match the vertex count, null is returned.
    public func GetTangents() -> [Vector4] {
        []
    }

    internal var texturesInternal: [Vector2] {
        get {
            m_Textures0
        }
        set {
            m_Textures0 = newValue
        }
    }

    internal var textures2Internal: [Vector4] {
        get {
            m_Textures2
        }
        set {
            m_Textures2 = newValue
        }
    }

    internal var textures3Internal: [Vector4] {
        get {
            m_Textures3
        }
        set {
            m_Textures3 = newValue
        }
    }

    /// The UV0 channel. Null if not present.
    public var textures: [Vector2] {
        get {
            []
        }
        set {

        }
    }

    /// Copy values in a UV channel to uvs.
    /// - Parameters:
    ///   - channel: The index of the UV channel to fetch values from. The valid range is `{0, 1, 2, 3}`.
    ///   - uvs: A list that will be cleared and populated with the UVs copied from this mesh.
    public func GetUVs(channel: Int, uvs: [Vector4]) {

    }

    internal func GetUVs(channel: Int) -> [Vector2] {
        []
    }

    /// Set the mesh UVs per-channel. Channels 0 and 1 are cast to Vector2, where channels 2 and 3 are kept Vector4.
    /// - Remark:
    /// Does not apply to mesh (use Refresh to reflect changes after application).
    /// - Parameters:
    ///   - channel: The index of the UV channel to fetch values from. The valid range is `{0, 1, 2, 3}`.
    ///   - uvs: The new UV values.
    public func SetUVs(channel: Int, uvs: [Vector4]) {

    }

    /// How many faces does this mesh have?
    public var faceCount: Int {
        get {
            0
        }
    }

    /// How many vertices are in the positions array.
    public var vertexCount: Int {
        get {
            0
        }
    }

    /// How many edges compose this mesh.
    public var edgeCount: Int {
        get {
            0
        }
    }

    /// How many vertex indexes make up this mesh.
    public var indexCount: Int {
        get {
            0
        }
    }

    /// How many triangles make up this mesh.
    public var triangleCount: Int {
        get {
            0
        }
    }

    internal var mesh: Mesh? {
        get {
            nil
        }
        set {

        }
    }

    internal var id: Int {
        get {
            0
        }
    }

    /// Ensure that the UnityEngine.Mesh is in sync with the ProBuilderMesh.
    /// A flag describing the state of the synchronicity between the MeshFilter.sharedMesh and ProBuilderMesh components.
    public var meshSyncState: MeshSyncState {
        get {
            MeshSyncState.Null
        }
    }

    internal var meshFormatVersion: Int {
        m_MeshFormatVersion
    }

    // MARK: - Functions
    static var s_CachedHashSet: Set<Int> = Set()

    public override func onAwake() {

    }

    func Reset() {
    }

    public override func onDestroy() {

    }

    func IncrementVersionIndex() {
    }

    /// Reset all the attribute arrays on this object.
    public func Clear() {
    }

    internal func EnsureMeshFilterIsAssigned() {
    }

    internal static func CreateInstanceWithPoints(engine: Engine, positions: [Vector3]) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new GameObject with a ProBuilderMesh component, MeshFilter, and MeshRenderer. All arrays are
    /// initialized as empty.
    /// - Parameter engine: engine
    /// - Returns: A reference to the new ProBuilderMesh component.
    public static func Create(engine: Engine) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new GameObject with a ProBuilderMesh component, MeshFilter, and MeshRenderer, then initializes the ProBuilderMesh with a set of positions and faces.
    /// - Parameters:
    ///   - engine: engine
    ///   - positions: Vertex positions array.
    ///   - faces: Faces array.
    /// - Returns: A reference to the new ProBuilderMesh component.
    public static func Create<T: Sequence<Vector3>, U: Sequence<Face>>(engine: Engine, positions: T, faces: U) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new GameObject with a ProBuilderMesh component, MeshFilter, and MeshRenderer, then initializes the ProBuilderMesh with a set of positions and faces.
    /// - Parameters:
    ///   - engine: engine
    ///   - vertices: Vertex positions array.
    ///   - faces: Faces array.
    ///   - sharedVertices: Optional SharedVertex[] defines coincident vertices.
    ///   - sharedTextures: Optional SharedVertex[] defines coincident texture coordinates (UV0).
    ///   - materials: Optional array of materials that will be assigned to the MeshRenderer.
    /// - Returns: GameObject
    public static func Create(engine: Engine,
                              vertices: [Vertex],
                              faces: [Face],
                              sharedVertices: [SharedVertex]? = nil,
                              sharedTextures: [SharedVertex]? = nil,
                              materials: [Material]? = nil) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    internal func GeometryWithPoints(_ points: [Vector3]) {
    }

    /// Clear all mesh attributes and reinitialize with new positions and face collections.
    /// - Parameters:
    ///   - vertices: Vertex positions array.
    ///   - faces: Faces array.
    public func RebuildWithPositionsAndFaces<T: Sequence<Vector3>, U: Sequence<Face>>(vertices: T, faces: U) {
    }

    /// Wraps <see cref="ToMesh"/> and <see cref="Refresh"/>.
    internal func Rebuild() {
    }

    /// Rebuild the mesh positions and submeshes. If vertex count matches new positions array the existing attributes are kept,
    /// otherwise the mesh is cleared. UV2 is the exception, it is always cleared.
    /// - Parameter preferredTopology: Triangles and Quads are supported.
    public func ToMesh(preferredTopology: MTLPrimitiveType = .triangle) {
    }

    /// Ensure that the UnityEngine.Mesh associated with this object is unique
    internal func MakeUnique() {
    }

    /// Copy mesh data from another mesh to self.
    public func CopyFrom(other: ProBuilderMesh) {
    }

    /// Recalculates mesh attributes: normals, collisions, UVs, tangents, and colors.
    /// - Parameter mask: Optionally pass a mask to define what components are updated (UV and collisions are expensive to rebuild, and can usually be deferred til completion of task).
    public func Refresh(mask: RefreshMask = RefreshMask.All) {

    }

    internal func EnsureMeshColliderIsAssigned() {

    }


    /// Returns a new unused texture group id.
    /// Will be greater than or equal to i.
    internal func GetUnusedTextureGroup(i: Int = 1) -> Int {
        0
    }

    static func IsValidTextureGroup(group: Int) -> Bool {
        false
    }


    /// Returns a new unused element group.
    /// Will be greater than or equal to i.
    internal func UnusedElementGroup(i: Int = 1) -> Int {
        0
    }

    public func RefreshUV<T: Sequence<Face>>(facesToRefresh: T) {
    }


    internal func SetGroupUV(settings: AutoUnwrapSettings, group: Int) {
    }


    func RefreshColors() {
    }

    /// Set the vertex colors for a @"UnityEngine.ProBuilder.Face".
    /// - Parameters:
    ///   - face: The target face.
    ///   - color: The color to set this face's referenced vertices to.
    public func SetFaceColor(face: Face, color: Color) {
    }

    /// Set the material for a collection of faces.
    /// - Remark:
    /// To apply the changes to the UnityEngine.Mesh, make sure to call ToMesh and Refresh.
    /// - Parameters:
    ///   - faces: The faces to apply the material to.
    ///   - material: The material to apply.
    public func SetMaterial<T: Sequence<Face>>(faces: T, material: Material) {
    }

    func RefreshNormals() {
    }


    func RefreshTangents() {
    }

    /// Find the index of a vertex index (triangle) in an IntArray[]. The index returned is called the common index, or shared index in some cases.
    /// - Parameter vertex: Aids in removing duplicate vertex indexes.
    /// - Returns: The common (or shared) index.
    internal func GetSharedVertexHandle(vertex: Int) -> Int {
        0
    }

    internal func GetSharedVertexHandles<T: Sequence<Int>>(vertices: T) -> Set<Int> {
        Set()
    }

    /// Get a list of vertices that are coincident to any of the vertices in the passed vertices parameter.
    /// - Parameter vertices: A collection of indexes relative to the mesh positions.
    /// - Returns: A list of all vertices that share a position with any of the passed vertices.
    public func GetCoincidentVertices<T: Sequence<Int>>(vertices: T) -> [Int] {
        []
    }

    /// Populate a list of vertices that are coincident to any of the vertices in the passed vertices parameter.
    /// - Parameters:
    ///   - faces: A collection of faces to gather vertices from.
    ///   - coincident: A list to be cleared and populated with any vertices that are coincident.
    public func GetCoincidentVertices<T: Sequence<Face>>(faces: T, coincident: [Int]) {
    }

    /// Populate a list of vertices that are coincident to any of the vertices in the passed vertices parameter.
    /// - Parameters:
    ///   - edges: A collection of edges to gather vertices from.
    ///   - coincident: A list to be cleared and populated with any vertices that are coincident.
    public func GetCoincidentVertices<T: Sequence<Edge>>(edges: T, coincident: [Int]) {
    }

    /// Populate a list of vertices that are coincident to any of the vertices in the passed vertices parameter.
    /// - Parameters:
    ///   - vertices: A collection of indexes relative to the mesh positions.
    ///   - coincident: A list to be cleared and populated with any vertices that are coincident.
    public func GetCoincidentVertices<T: Sequence<Int>>(vertices: T, coincident: [Int]) {
    }

    /// Populate a list with all the vertices that are coincident to the requested vertex.
    /// - Parameters:
    ///   - vertex: An index relative to a positions array.
    ///   - coincident: A list to be populated with all coincident vertices.
    public func GetCoincidentVertices(_ vertex: Int, coincident: [Int]) {
    }

    /// Sets the passed vertices as being considered coincident by the ProBuilderMesh.
    /// - Remark:
    /// Note that it is up to the caller to ensure that the passed vertices are indeed sharing a position.
    /// - Parameter vertices: Returns a list of vertices to be associated as coincident.
    public func SetVerticesCoincident<T: Sequence<Int>>(vertices: T) {
    }

    internal func SetTexturesCoincident<T: Sequence<Int>>(vertices: T) {
    }


    internal func AddToSharedVertex(_ sharedVertexHandle: Int, vertex: Int) {
    }


    internal func AddSharedVertex(_ vertex: SharedVertex) {
    }

    // MARK: - Selection
    var m_IsSelectable = true

    // Serialized for undo in the editor
    var m_SelectedFaces: [Int] = []
    var m_SelectedEdges: [Edge] = []
    var m_SelectedVertices: [Int] = []

    var m_SelectedCacheDirty: Bool = false
    var m_SelectedSharedVerticesCount = 0
    var m_SelectedCoincidentVertexCount = 0
    var m_SelectedSharedVertices: Set<Int> = Set()
    var m_SelectedCoincidentVertices: [Int] = []

    /// If false mesh elements will not be selectable. This is used by @"UnityEditor.ProBuilder.ProBuilderEditor".
    public var selectable: Bool {
        get {
            m_IsSelectable
        }
        set {
            m_IsSelectable = newValue
        }
    }

    /// Get the number of faces that are currently selected on this object.
    public var selectedFaceCount: Int {
        get {
            m_SelectedFaces.count
        }
    }

    /// Get the number of selected vertex indexes.
    public var selectedVertexCount: Int {
        get {
            m_SelectedVertices.count
        }
    }

    /// Get the number of selected edges.
    public var selectedEdgeCount: Int {
        get {
            m_SelectedEdges.count
        }
    }

    internal var selectedSharedVerticesCount: Int {
        get {
            CacheSelection()
            return m_SelectedSharedVerticesCount
        }
    }

    internal var selectedCoincidentVertexCount: Int {
        get {
            CacheSelection()
            return m_SelectedCoincidentVertexCount
        }
    }

    internal var selectedSharedVertices: any Sequence<Int> {
        get {
            CacheSelection()
            return m_SelectedSharedVertices
        }
    }

    /// All selected vertices and their coincident neighbors.
    internal var selectedCoincidentVertices: [Int] {
        get {
            CacheSelection()
            return m_SelectedCoincidentVertices
        }
    }

    func CacheSelection() {
    }

    /// Get a copy of the selected face array.
    public func GetSelectedFaces() -> [Face] {
        []
    }

    /// A collection of the currently selected faces by their index in the @"UnityEngine.ProBuilder.ProBuilderMesh.faces" array.
    public var selectedFaceIndexes: [Int] {
        get {
            m_SelectedFaces
        }
    }

    /// A collection of the currently selected vertices by their index in the @"UnityEngine.ProBuilder.ProBuilderMesh.positions" array.
    public var selectedVertices: [Int] {
        get {
            m_SelectedVertices
        }
    }

    /// A collection of the currently selected edges.
    public var selectedEdges: [Edge] {
        get {
            m_SelectedEdges
        }
    }

    internal var selectedFacesInternal: [Face] {
        get {
            GetSelectedFaces()
        }
        set {
        }
    }

    internal var selectedFaceIndicesInternal: [Int] {
        get {
            return m_SelectedFaces
        }
        set {
            m_SelectedFaces = newValue
        }
    }

    internal var selectedEdgesInternal: [Edge] {
        get {
            return m_SelectedEdges
        }
        set {
            m_SelectedEdges = newValue
        }
    }

    internal var selectedIndexesInternal: [Int] {
        get {
            return m_SelectedVertices
        }
        set {
            m_SelectedVertices = newValue
        }
    }

    internal func GetActiveFace() -> Face {
        Face()
    }

    internal func GetActiveEdge() -> Edge {
        Edge(0, 0)
    }

    internal func GetActiveVertex() -> Int {
        0
    }

    internal func AddToFaceSelection(at index: Int) {
    }

    /// Set the face selection for this mesh. Also sets the vertex and edge selection to match.
    /// - Parameter selected: The new face selection.
    public func SetSelectedFaces<T: Sequence<Face>>(_ selected: T) {

    }

    internal func SetSelectedFaces<T: Sequence<Int>>(_ selected: T) {

    }

    /// Set the edge selection for this mesh. Also sets the face and vertex selection to match.
    /// - Parameter edges: The new edge selection.
    public func SetSelectedEdges<T: Sequence<Edge>>(_ edges: T) {
    }

    /// Sets the selected vertices array. Clears SelectedFaces and SelectedEdges arrays.
    /// - Parameter vertices: The new vertex selection.
    public func SetSelectedVertices<T: Sequence<Int>>(_ vertices: T) {
    }

    /// Removes face at index in SelectedFaces array, and updates the SelectedTriangles and SelectedEdges arrays to match.
    internal func RemoveFromFaceSelectionAtIndex(_ index: Int) {
    }

    /// Clears selected face, edge, and vertex arrays. You do not need to call this when setting an individual array,
    /// as the setter methods will handle updating the associated caches.
    public func ClearSelection() {
    }
}
