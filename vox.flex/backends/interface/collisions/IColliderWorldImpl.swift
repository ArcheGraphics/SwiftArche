//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public protocol IColliderWorldImpl {
    var referenceCount: Int { get }

    func UpdateWorld(deltaTime: Float)

    func SetColliders(shapes: [ColliderShape],
                      bounds: [Aabb],
                      transforms: [AffineTransform],
                      count: Int)
    func SetRigidbodies(rigidbody: [ColliderRigidbody])

    func SetCollisionMaterials(materials: [CollisionMaterial])

    func SetTriangleMeshData(headers: [TriangleMeshHeader],
                             nodes: [BIHNode],
                             triangles: [Triangle],
                             vertices: [Vector3])
    func SetEdgeMeshData(headers: [EdgeMeshHeader],
                         nodes: [BIHNode],
                         triangles: [Edge],
                         vertices: [Vector2])
    func SetDistanceFieldData(headers: [DistanceFieldHeader],
                              nodes: [DFNode])
    func SetHeightFieldData(headers: [HeightFieldHeader],
                            samples: [Float])
}
