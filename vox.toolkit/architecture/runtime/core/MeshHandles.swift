//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class MeshHandles {
    static var s_Vector2List: [Vector3] = []
    static var s_Vector3List: [Vector3] = []
    static var s_Vector4List: [Vector4] = []
    static var s_IndexList: [Int] = []
    static var s_SharedVertexIndexList: [Int] = []

    static let k_Billboard0 = Vector2(-1, -1)
    static let k_Billboard1 = Vector2(-1, 1)
    static let k_Billboard2 = Vector2(1, -1)
    static let k_Billboard3 = Vector2(1, 1)

    internal static func CreateFaceMesh(mesh _: ProBuilderMesh, target _: Mesh) {}

    internal static func CreateFaceMeshFromFaces(mesh _: ProBuilderMesh, faces _: [Face], target _: Mesh) {}

    internal static func CreateEdgeMesh(mesh _: ProBuilderMesh, target _: Mesh) {}

    internal static func CreateEdgeMesh(mesh _: ProBuilderMesh, target _: Mesh, edges _: [Edge]) {}

    internal static func CreateVertexMesh(mesh _: ProBuilderMesh, target _: Mesh) {}

    internal static func CreateVertexMesh(mesh _: ProBuilderMesh, target _: Mesh, indexes _: [Int]) {}

    static func CreatePointMesh(positions _: [Vector3], indexes _: [Int], target _: Mesh) {}

    internal static func CreatePointBillboardMesh(positions _: [Vector3], target _: Mesh) {}

    static func CreatePointBillboardMesh(positions _: [Vector3], indexes _: [Int], target _: Mesh) {}

    internal static func CreateEdgeBillboardMesh(mesh _: ProBuilderMesh, target _: Mesh) {}

    internal static func CreateEdgeBillboardMesh<T: Collection<Edge>>(mesh _: ProBuilderMesh, target _: Mesh, edges _: T) {}
}
