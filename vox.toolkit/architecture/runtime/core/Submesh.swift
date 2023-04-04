//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// A set of indexes and material.
public final class Submesh {
    internal var m_Indexes: [Int] = []

    internal var m_Topology: MTLPrimitiveType = .triangle

    internal var m_SubmeshIndex: Int = 0

    /// Indexes making up this submesh. Can be triangles or quads, check with topology.
    public var indexes: [Int] {
        get {
            m_Indexes
        }
        set {
            m_Indexes = newValue
        }
    }

    /// What is the topology (triangles, quads) of this submesh?
    public var topology: MTLPrimitiveType {
        get {
            m_Topology
        }
        set {
            m_Topology = newValue
        }
    }

    /// The index in the sharedMaterials array that this submesh aligns with.
    public var submeshIndex: Int {
        get {
            m_SubmeshIndex
        }
        set {
            m_SubmeshIndex = newValue
        }
    }

    /// Create new Submesh.
    /// - Parameters:
    ///   - submeshIndex: The index of this submesh corresponding to the MeshRenderer.sharedMaterials property.
    ///   - topology: What topology is this submesh. ProBuilder only recognizes Triangles and Quads.
    ///   - indexes: The triangles or quads.
    public init<T: Sequence<Int>>(submeshIndex _: Int, topology _: MTLPrimitiveType, indexes _: T) {}

    /// Create new Submesh from a mesh, submesh index, and material.
    /// - Parameters:
    ///   - mesh: The source mesh.
    ///   - subMeshIndex: Which submesh to read from.
    public init(mesh _: Mesh, subMeshIndex _: Int) {}

    internal static func GetSubmeshCount(mesh _: ProBuilderMesh) -> Int {
        0
    }

    /// Create submeshes from a set of faces. Currently only Quads and Triangles are supported.
    /// - Parameters:
    ///   - faces: The faces to be included in the resulting submeshes. This method handles groups submeshes by comparing the material property of each face.
    ///   - submeshCount: How many submeshes to create. Usually you will just want to pass the length of the MeshRenderer.sharedMaterials array.
    ///   - preferredTopology: Should the resulting submeshes be in quads or triangles. Note that quads are not guaranteed
    ///   ie, some faces may not be able to be represented in quad format and will fall back on triangles.
    /// - Returns: An array of Submeshes.
    public static func GetSubmeshes<T: Sequence<Face>>(faces _: T, submeshCount _: Int,
                                                       preferredTopology _: MTLPrimitiveType = .triangle) -> [Submesh]
    {
        []
    }

    internal static func MapFaceMaterialsToSubmeshIndex(mesh _: ProBuilderMesh) {}
}

extension Submesh: CustomStringConvertible {
    public var description: String {
        ""
    }
}
