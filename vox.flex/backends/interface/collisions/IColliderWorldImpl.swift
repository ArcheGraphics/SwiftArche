//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public protocol IColliderWorldImpl {
    var referenceCount: Int { get }

    func UpdateWorld(deltaTime: Float)

    func SetColliders(shapes: ObiNativeColliderShapeList,
                      bounds: ObiNativeAabbList,
                      transforms: ObiNativeAffineTransformList,
                      count: Int)
    func SetRigidbodies(rigidbody: ObiNativeRigidbodyList)

    func SetCollisionMaterials(materials: ObiNativeCollisionMaterialList)

    func SetTriangleMeshData(headers: ObiNativeTriangleMeshHeaderList,
                             nodes: ObiNativeBIHNodeList,
                             triangles: ObiNativeTriangleList,
                             vertices: ObiNativeVector3List)
    func SetEdgeMeshData(headers: ObiNativeEdgeMeshHeaderList,
                         nodes: ObiNativeBIHNodeList,
                         triangles: ObiNativeEdgeList,
                         vertices: ObiNativeVector2List)
    func SetDistanceFieldData(headers: ObiNativeDistanceFieldHeaderList,
                              nodes: ObiNativeDFNodeList)
    func SetHeightFieldData(headers: ObiNativeHeightFieldHeaderList,
                            samples: ObiNativeFloatList)
}
