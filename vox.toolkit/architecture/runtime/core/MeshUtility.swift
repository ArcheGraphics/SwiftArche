//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Functions for generating mesh attributes and various other mesh utilities.
public enum MeshUtility {
    /// Create an array of @"UnityEngine.ProBuilder.Vertex" values that are ordered as individual triangles. This modifies the source mesh to match the new individual triangles format.
    /// - Parameter mesh: The mesh to extract vertices from, and apply per-triangle topology to.
    /// - Returns: A @"UnityEngine.ProBuilder.Vertex" array of the per-triangle vertices.
    internal static func GeneratePerTriangleMesh(mesh _: Mesh) -> [Vertex] {
        []
    }

    /// Generate tangents and apply them.
    /// - Parameter mesh: The UnityEngine.Mesh mesh target.
    public static func GenerateTangent(mesh _: Mesh) {}

    /// Performs a deep copy of a mesh and returns a new mesh object.
    /// - Parameter source: The source mesh.
    /// - Returns: A new UnityEngine.Mesh object with the same values as source.
    public static func DeepCopy(source _: Mesh) -> Mesh {
        Mesh()
    }

    /// Copy source mesh values to destination mesh.
    /// - Parameters:
    ///   - source: The mesh from which to copy attributes.
    ///   - destination: The destination mesh to copy attribute values to.
    public static func CopyTo(source _: Mesh, destination _: Mesh) {}

    /// Get a mesh attribute from either the MeshFilter.sharedMesh or the MeshRenderer.additionalVertexStreams mesh. The additional vertex stream mesh has priority.
    /// - Remark:
    /// The type of the attribute to fetch.
    /// - Parameters:
    ///   - gameObject: The GameObject with the MeshFilter and (optional) MeshRenderer to search for mesh attributes.
    ///   - attributeGetter: The function used to extract mesh attribute.
    /// - Returns: A List of the mesh attribute values from the Additional Vertex Streams mesh if it exists and contains the attribute, or the MeshFilter.sharedMesh attribute values.
    internal static func GetMeshChannel<T>(gameObject _: Entity, attributeGetter _: (Mesh, [T])) -> [T] {
        []
    }

    /// Print a detailed string summary of the mesh attributes.
    public static func Print(mesh _: Mesh) -> String {
        ""
    }

    /// Get the number of indexes this mesh contains.
    /// - Parameter mesh: The source mesh to sum submesh index counts from.
    /// - Returns: The count of all indexes contained within this meshes submeshes.
    public static func GetIndexCount(mesh _: Mesh) -> UInt {
        0
    }

    /// Get the number of triangles or quads this mesh contains. Other mesh topologies are not considered.
    /// - Parameter mesh: The source mesh to sum submesh primitive counts from.
    /// - Returns: The count of all triangles or quads contained within this meshes submeshes.
    public static func GetPrimitiveCount(mesh _: Mesh) -> UInt {
        0
    }

    /// Compile a UnityEngine.Mesh from a ProBuilderMesh.
    /// - Parameters:
    ///   - probuilderMesh: The mesh source.
    ///   - targetMesh: Destination UnityEngine.Mesh.
    ///   - preferredTopology: If specified, the function will try to create topology matching the reqested format (and falling back on triangles where necessary).
    public static func Compile(probuilderMesh _: ProBuilderMesh, targetMesh _: Mesh, preferredTopology _: MTLPrimitiveType = .triangle) {}

    /// Creates a new array of vertices with values from a UnityEngine.Mesh.
    /// - Parameter mesh: The source mesh.
    /// - Returns: An array of vertices.
    public static func GetVertices(mesh _: Mesh) -> [Vertex] {
        []
    }

    /// Merge coincident vertices where possible, optimizing the vertex count of a UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to optimize.
    ///   - vertices: If provided these values are used in place of extracting attributes from the Mesh.
    ///   This is a performance optimization for when this array already exists. If not provided this array will be
    /// automatically generated for you.
    public static func CollapseSharedVertices(mesh _: Mesh, vertices _: [Vertex]? = nil) {}

    /// Scale mesh vertices to fit within a bounds size.
    /// - Parameters:
    ///   - mesh: The mesh to apply scaling to.
    ///   - currentSize: The bounding size of the original shape we want to fit.
    ///   - sizeToFit: The size to fit mesh contents within.
    public static func FitToSize(mesh _: ProBuilderMesh, currentSize _: Bounds, sizeToFit _: Vector3) {}

    internal static func SanityCheck(mesh _: ProBuilderMesh) -> String {
        ""
    }

    /// Check mesh for invalid properties.
    /// - Parameter mesh: mesh
    /// - Returns: Returns true if mesh is valid, false if a problem was found.
    internal static func SanityCheck(mesh _: Mesh) -> String {
        ""
    }

    /// Check mesh for invalid properties.
    /// - Parameter vertices: vertices
    /// - Returns: Returns true if mesh is valid, false if a problem was found.
    internal static func SanityCheck(vertices _: [Vertex]) -> String {
        ""
    }

    internal static func IsUsedInParticleSystem(pbmesh _: ProBuilderMesh) -> Bool {
        false
    }

    internal static func RestoreParticleSystem(pbmesh _: ProBuilderMesh) {}

    internal static func GetBounds(mesh _: ProBuilderMesh) -> Bounds {
        Bounds()
    }
}
