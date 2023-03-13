//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// A face is composed of a set of triangles, and a material.
///
/// Triangle indexes may point to the same vertex index as long as the vertices are unique to the face.
/// Ie, every vertex that a face references should only be used by that face's indices.
/// To associate vertices that share common attributes (usually position), use the @"UnityEngine.ProBuilder.ProBuilderMesh.sharedIndexes" property.
///
/// ProBuilder automatically manages condensing common vertices in the EditorMeshUtility.Optimize function.
public final class Face {
    var m_Indexes: [Int] = []

    /// Adjacent faces sharing this smoothingGroup will have their abutting edge normals averaged.
    var m_SmoothingGroup: Int = 0

    /// If manualUV is false, these parameters determine how this face's vertices are projected to 2d space.
    var m_Uv: AutoUnwrapSettings = .defaultAutoUnwrapSettings

    /// What material does this face use.
    var m_Material: Material!

    var m_SubmeshIndex: Int = 0

    var m_ManualUV: Bool = false

    /// If this face has had it's UV coordinates done by hand, don't update them with the auto unwrap crowd.
    public var manualUV: Bool {
        get {
            m_ManualUV
        }
        set {
            m_ManualUV = newValue
        }
    }

    /// UV element group. Used by the UV editor to group faces.
    internal var elementGroup: Int = 0

    var m_TextureGroup: Int = 0

    /// What texture group this face belongs to. Used when projecting auto UVs.
    public var textureGroup: Int {
        get {
            m_TextureGroup
        }
        set {
            m_TextureGroup = newValue
        }
    }

    /// Return a reference to the triangle indexes that make up this face.
    internal var indexesInternal: [Int] {
        get {
            m_Indexes
        }
        set {
            if (m_Indexes.count % 3 != 0) {
                fatalError("Face indexes must be a multiple of 3.")
            }
            m_Indexes = newValue
            InvalidateCache()
        }
    }

    /// The triangle indexes that make up this face.
    public var indexes: [Int] {
        get {
            m_Indexes
        }
    }

    /// Set the triangles that compose this face.
    /// - Parameter indices: The new triangle array.
    public func SetIndexes<T>(indices: T) where T: Sequence<Int> {
        let array = [Int](indices)
        let len = array.count
        if (len % 3 != 0) {
            fatalError("Face indexes must be a multiple of 3.")
        }
        m_Indexes = array
        InvalidateCache()
    }

    var m_DistinctIndexes: [Int]?

    var m_Edges: [Edge]?

    /// Returns a reference to the cached distinct indexes (each vertex index is only referenced once in m_DistinctIndexes).
    internal var distinctIndexesInternal: [Int]? {
        get {
            return m_DistinctIndexes == nil ? CacheDistinctIndexes() : m_DistinctIndexes
        }
    }

    /// A collection of the vertex indexes that the indexes array references, made distinct.
    public var distinctIndexes: [Int]? {
        get {
            distinctIndexesInternal
        }
    }

    internal var edgesInternal: [Edge]? {
        get {
            return m_Edges == nil ? CacheEdges() : m_Edges
        }
    }

    /// Get the perimeter edges that commpose this face.
    public var edges: [Edge]? {
        get {
            edgesInternal
        }
    }

    /// What smoothing group this face belongs to, if any. This is used to calculate vertex normals.
    public var smoothingGroup: Int {
        get {
            m_SmoothingGroup
        }
        set {
            m_SmoothingGroup = newValue
        }
    }

    /// Get the material that face uses.
    public var material: Material {
        get {
            m_Material
        }
        set {
            m_Material = newValue
        }
    }

    public var submeshIndex: Int {
        get {
            m_SubmeshIndex
        }
        set {
            m_SubmeshIndex = newValue
        }
    }

    /// A reference to the Auto UV mapping parameters.
    public var uv: AutoUnwrapSettings {
        get {
            m_Uv
        }
        set {
            m_Uv = newValue
        }
    }

    /// Default constructor creates a face with an empty triangles array.
    public init() {
        m_SubmeshIndex = 0
    }

    /// Initialize a Face with a set of triangles and default values.
    /// - Parameter indices: The new triangles array.
    public init(indices: [Int]) {
        SetIndexes(indices: indices)
        m_Uv = AutoUnwrapSettings.tile
//        m_Material = BuiltinMaterials.defaultMaterial
        m_SmoothingGroup = Smoothing.smoothingGroupNone
        m_SubmeshIndex = 0
        textureGroup = -1
        elementGroup = 0
    }

    internal init(triangles: [Int], m: Material, u: AutoUnwrapSettings, smoothing: Int,
                  texture: Int, element: Int, manualUVs: Bool) {
        SetIndexes(indices: triangles)
        m_Uv = u
        m_Material = m
        m_SmoothingGroup = smoothing
        textureGroup = texture
        elementGroup = element
        manualUV = manualUVs
        m_SubmeshIndex = 0
    }

    internal init(triangles: [Int], submeshIndex: Int, u: AutoUnwrapSettings, smoothing: Int,
                  texture: Int, element: Int, manualUVs: Bool) {
        SetIndexes(indices: triangles)
        m_Uv = u
        m_SmoothingGroup = smoothing
        textureGroup = texture
        elementGroup = element
        manualUV = manualUVs
        m_SubmeshIndex = submeshIndex
    }
    
    /// Deep copy constructor.
    /// - Parameter other: The Face from which to copy properties.
    public init(other: Face) {
        CopyFrom(other: other)
    }

    /// Copies values from other to this face.
    /// - Parameter other: The Face from which to copy properties.
    public func CopyFrom(other: Face) {
    }

    internal func InvalidateCache() {
    }

    func CacheEdges() -> [Edge] {
        []
    }

    func CacheDistinctIndexes() -> [Int] {
        []
    }

    /// Test if a triangle is contained within the triangles array of this face.
    public func Contains(a: Int, b: Int, c: Int) -> Bool {
        false
    }

    /// Is this face representable as quad?
    public func IsQuad() -> Bool {
        false
    }

    /// Convert a 2 triangle face to a quad representation.
    /// - Returns: A quad (4 indexes), or null if indexes are not able to be represented as a quad.
    public func ToQuad() -> [Int] {
        []
    }

    /// Add offset to each value in the indexes array.
    /// - Parameter offset: The value to add to each index.
    public func ShiftIndexes(offset: Int) {
    }

    /// Find the smallest value in the triangles array.
    /// - Returns: The smallest value in the indexes array.
    func SmallestIndexValue() -> Int {
        0
    }

    /// Finds the smallest value in the indexes array, then offsets by subtracting that value from each index.
    /// ```
    /// // sets the indexes array to `{0, 1, 2}`.
    /// new Face(3,4,5).ShiftIndexesToZero()
    /// ```
    public func ShiftIndexesToZero() {
    }

    /// Reverse the order of the triangle array. This has the effect of reversing the direction that this face renders.
    public func Reverse() {
    }

    internal static func GetIndices(faces: [Face], indices: [Int]) {
    }

    internal static func GetDistinctIndices(faces: [Face], indices: [Int]) {
    }

    /// Advance to the next connected edge given a source edge and the index connect.
    internal func TryGetNextEdge(source: Edge, index: Int, nextEdge: inout Edge, nextIndex: inout Int) -> Bool {
        false
    }
}

extension Face: Hashable {
    public func hash(into hasher: inout Hasher) {

    }

    public static func ==(lhs: Face, rhs: Face) -> Bool {
        false
    }


}
