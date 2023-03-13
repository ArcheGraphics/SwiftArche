//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Functions for generating mesh attributes and various other mesh utilities.
public class MeshUtility {
    /// Create an array of @"UnityEngine.ProBuilder.Vertex" values that are ordered as individual triangles. This modifies the source mesh to match the new individual triangles format.
    /// - Parameter mesh: The mesh to extract vertices from, and apply per-triangle topology to.
    /// - Returns: A @"UnityEngine.ProBuilder.Vertex" array of the per-triangle vertices.
    internal static func GeneratePerTriangleMesh(mesh: Mesh) -> [Vertex] {
        []
    }
    
    /// Generate tangents and apply them.
    /// - Parameter mesh: The UnityEngine.Mesh mesh target.
    public static func GenerateTangent(mesh: Mesh) {
    }
    
    /// Performs a deep copy of a mesh and returns a new mesh object.
    /// - Parameter source: The source mesh.
    /// - Returns: A new UnityEngine.Mesh object with the same values as source.
    public static func DeepCopy(source: Mesh) -> Mesh {
        Mesh()
    }
    
    /// Copy source mesh values to destination mesh.
    /// - Parameters:
    ///   - source: The mesh from which to copy attributes.
    ///   - destination: The destination mesh to copy attribute values to.
    public static func CopyTo(source: Mesh, destination: Mesh) {
    }

    /// Get a mesh attribute from either the MeshFilter.sharedMesh or the MeshRenderer.additionalVertexStreams mesh. The additional vertex stream mesh has priority.
    /// - Remark:
    /// The type of the attribute to fetch.
    /// - Parameters:
    ///   - gameObject: The GameObject with the MeshFilter and (optional) MeshRenderer to search for mesh attributes.
    ///   - attributeGetter: The function used to extract mesh attribute.
    /// - Returns: A List of the mesh attribute values from the Additional Vertex Streams mesh if it exists and contains the attribute, or the MeshFilter.sharedMesh attribute values.
    internal static func GetMeshChannel<T>(gameObject: Entity, attributeGetter: (Mesh, [T])) -> [T] {
        []
    }

    /// Print a detailed string summary of the mesh attributes.
    public static func Print(mesh: Mesh) -> String {
        ""
    }

    /// Get the number of indexes this mesh contains.
    /// - Parameter mesh: The source mesh to sum submesh index counts from.
    /// - Returns: The count of all indexes contained within this meshes submeshes.
    public static func GetIndexCount(mesh: Mesh) -> UInt {
        0
    }
    
    /// Get the number of triangles or quads this mesh contains. Other mesh topologies are not considered.
    /// - Parameter mesh: The source mesh to sum submesh primitive counts from.
    /// - Returns: The count of all triangles or quads contained within this meshes submeshes.
    public static func GetPrimitiveCount(mesh: Mesh) -> UInt {
        0
    }

    /// Compile a UnityEngine.Mesh from a ProBuilderMesh.
    /// - Parameters:
    ///   - probuilderMesh: The mesh source.
    ///   - targetMesh: Destination UnityEngine.Mesh.
    ///   - preferredTopology: If specified, the function will try to create topology matching the reqested format (and falling back on triangles where necessary).
    public static func Compile(probuilderMesh: ProBuilderMesh, targetMesh: Mesh, preferredTopology: MTLPrimitiveType = .triangle) {
    }
    
    /// Creates a new array of vertices with values from a UnityEngine.Mesh.
    /// - Parameter mesh: The source mesh.
    /// - Returns: An array of vertices.
    public static func GetVertices(mesh: Mesh) -> [Vertex] {
        []
    }

    
    /// Merge coincident vertices where possible, optimizing the vertex count of a UnityEngine.Mesh.
    /// - Parameters:
    ///   - mesh: The mesh to optimize.
    ///   - vertices: If provided these values are used in place of extracting attributes from the Mesh.
    ///   This is a performance optimization for when this array already exists. If not provided this array will be
    /// automatically generated for you.
    public static func CollapseSharedVertices(mesh: Mesh, vertices: [Vertex]? = nil) {
    }

    /// Scale mesh vertices to fit within a bounds size.
    /// - Parameters:
    ///   - mesh: The mesh to apply scaling to.
    ///   - currentSize: The bounding size of the original shape we want to fit.
    ///   - sizeToFit: The size to fit mesh contents within.
    public static func FitToSize(mesh: ProBuilderMesh, currentSize: Bounds, sizeToFit: Vector3) {
    }

    internal static func SanityCheck(mesh: ProBuilderMesh) -> String {
        ""
    }
    
    /// Check mesh for invalid properties.
    /// - Parameter mesh: mesh
    /// - Returns: Returns true if mesh is valid, false if a problem was found.
    internal static func SanityCheck(mesh: Mesh) -> String {
        ""
    }
    
    /// Check mesh for invalid properties.
    /// - Parameter vertices: vertices
    /// - Returns: Returns true if mesh is valid, false if a problem was found.
    internal static func SanityCheck(vertices: [Vertex]) -> String {
        ""
    }

    internal static func IsUsedInParticleSystem(pbmesh: ProBuilderMesh) -> Bool {
        false
    }


    internal static func RestoreParticleSystem(pbmesh: ProBuilderMesh) {
    }


    internal static func GetBounds(mesh: ProBuilderMesh) -> Bounds {
        Bounds()
    }

}
