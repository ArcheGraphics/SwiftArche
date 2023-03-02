//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Static methods for working with ProBuilderMesh objects in an editor.
extension Camera {
    /// Convert a screen point (0,0 bottom left, in pixels) to a GUI point (0,0 top left, in points).
    internal static func ScreenToGuiPoint(point: Vector3, pixelsPerPoint: Float) -> Vector3 {
        Vector3()
    }
}

extension Transform {
    /// Transform a ray from world space to a transform local space.
    internal static func InverseTransformRay(_ InWorldRay: Ray) -> Ray {
        Ray()
    }
}


public class HandleUtility {
    /// Find a triangle intersected by InRay on InMesh.  InRay is in world space.
    /// Returns the index in mesh.faces of the hit face, or -1.  Optionally can ignore backfaces.
    internal static func FaceRaycast(worldRay: Ray, mesh: ProBuilderMesh,
                                     hit: inout HitResult, ignore: Set<Face>? = nil) -> Bool {
        FaceRaycast(worldRay: worldRay, mesh: mesh, hit: &hit, distance: Float.infinity,
                cullingMode: CullingMode.Back, ignore: ignore)
    }

    /// Find the nearest face intersected by InWorldRay on this pb_Object.
    /// - Parameters:
    ///   - worldRay: A ray in world space.
    ///   - mesh: The ProBuilder object to raycast against.
    ///   - hit: If the mesh was intersected, hit contains information about the intersect point in local coordinate space.
    ///   - distance: Which sides of a face are culled when hit testing. Default is back faces are culled.
    ///   - cullingMode: Optional collection of faces to ignore when raycasting.
    ///   - ignore: Optional collection of faces to ignore when raycasting.
    /// - Returns: True if the ray intersects with the mesh, false if not.
    internal static func FaceRaycast(worldRay: Ray, mesh: ProBuilderMesh, hit: inout HitResult, distance: Float,
                                     cullingMode: CullingMode, ignore: Set<Face>? = nil) -> Bool {
        false
    }

    internal static func FaceRaycastBothCullModes(worldRay: Ray, mesh: ProBuilderMesh,
                                                  back: inout (Face, Vector3), front: inout (Face, Vector3)) -> Bool {
        false
    }

    /// Find the all faces intersected by InWorldRay on this pb_Object.
    /// - Parameters:
    ///   - InWorldRay: A ray in world space.
    ///   - mesh: The ProBuilder object to raycast against.
    ///   - hits: If the mesh was intersected, hits contains all intersection point RaycastHit information.
    ///   - cullingMode: What sides of triangles does the ray intersect with.
    ///   - ignore: Optional collection of faces to ignore when raycasting.
    /// - Returns: True if the ray intersects with the mesh, false if not.
    internal static func FaceRaycast(
            InWorldRay: Ray,
            mesh: ProBuilderMesh,
            hits: inout [HitResult],
            cullingMode: CullingMode,
            ignore: Set<Face>? = nil) -> Bool {
        false
    }

    /// Find the nearest triangle intersected by InWorldRay on this mesh.
    internal static func MeshRaycast(InWorldRay: Ray, gameObject: Entity,
                                     hit: inout HitResult, distance: Float = Float.infinity) -> Float {
        0
    }

    /// Cast a ray (in model space) against a mesh.
    internal static func MeshRaycast(InRay: Ray, mesh: [Vector3], triangles: [Int],
                                     hit: inout HitResult, distance: Float = Float.infinity) -> Float {
        0
    }

    /// Returns true if this point in world space is occluded by a triangle on this object.
    /// - Remark: This is very slow, do not use.
    internal static func PointIsOccluded(cam: Camera, pb: ProBuilderMesh, worldPoint: Vector3) -> Bool {
        false
    }

    /// Collects coincident vertices and returns a rotation calculated from the average normal and bitangent.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - indices: Vertex indices to consider in the rotation calculations.
    /// - Returns: A rotation calculated from the average normal of each vertex.
    public static func GetRotation<T: Sequence<Int>>(from mesh: ProBuilderMesh, indices: T) -> Quaternion {
        Quaternion()
    }

    /// Get a rotation suitable for orienting a handle or gizmo relative to the element selection.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - orientation: The type of <see cref="HandleOrientation"/> to calculate.
    ///   - faces: Faces to consider in the rotation calculations. Only used when
    ///   <see cref="HandleOrientation"/> is <see cref="HandleOrientation.ActiveElement"/>.</param>
    /// - Returns: A rotation appropriate to the orientation and element selection.
    public static func GetFaceRotation<T: Sequence<Face>>(mesh: ProBuilderMesh, orientation: HandleOrientation, faces: T) -> Quaternion {
        Quaternion()
    }

    /// Get the rotation of a face in world space.
    /// - Parameters:
    ///   - mesh: The mesh that face belongs to.
    ///   - face: The face calculate rotation for.
    /// - Returns: The rotation of face in world space coordinates.
    public static func GetFaceRotation(mesh: ProBuilderMesh, face: Face) -> Quaternion {
        Quaternion()
    }

    /// Get a rotation suitable for orienting a handle or gizmo relative to the element selection.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - orientation: The type of <see cref="HandleOrientation"/> to calculate.
    ///   - edges: Edges to consider in the rotation calculations. Only used when
    ///   <see cref="HandleOrientation"/> is <see cref="HandleOrientation.ActiveElement"/>.</param>
    /// - Returns: A rotation appropriate to the orientation and element selection.
    public static func GetEdgeRotation<T: Sequence<Edge>>(mesh: ProBuilderMesh, orientation: HandleOrientation, edges: T) -> Quaternion {
        Quaternion()
    }

    /// Get the rotation of an edge in world space.
    /// - Parameters:
    ///   - mesh: The mesh that edge belongs to.
    ///   - edge: The edge calculate rotation for.
    /// - Returns: The rotation of edge in world space coordinates.
    public static func GetEdgeRotation(mesh: ProBuilderMesh, edge: Edge) -> Quaternion {
        Quaternion()
    }

    /// Get a rotation suitable for orienting a handle or gizmo relative to the element selection.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - orientation: The type of <see cref="HandleOrientation"/> to calculate.
    ///   - vertices: Edges to consider in the rotation calculations. Only used when
    /// <see cref="HandleOrientation"/> is <see cref="HandleOrientation.ActiveElement"/>.</param>
    /// - Returns: A rotation appropriate to the orientation and element selection.
    public static func GetVertexRotation<T: Sequence<Int>>(mesh: ProBuilderMesh, orientation: HandleOrientation, vertices: T) -> Quaternion {
        Quaternion()
    }

    /// Get the rotation of a vertex in world space.
    /// - Parameters:
    ///   - mesh: The mesh that `vertex` belongs to.
    ///   - vertex: The vertex to calculate rotation for.
    /// - Returns: The rotation of a vertex normal in world space coordinates.
    public static func GetVertexRotation(mesh: ProBuilderMesh, vertex: Int) -> Quaternion {
        Quaternion()
    }

    internal static func GetActiveElementPosition<T: Sequence<Face>>(mesh: ProBuilderMesh, faces: T) -> Vector3 {
        Vector3()
    }

    internal static func GetActiveElementPosition<T: Sequence<Edge>>(mesh: ProBuilderMesh, edges: T) -> Vector3 {
        Vector3()
    }

    internal static func GetActiveElementPosition<T: Sequence<Int>>(mesh: ProBuilderMesh, vertices: T) -> Vector3 {
        Vector3()
    }
}
