//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

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

    internal static func CreateFaceMesh(mesh: ProBuilderMesh, target: Mesh) {
    }

    internal static func CreateFaceMeshFromFaces(mesh: ProBuilderMesh, faces: [Face], target: Mesh) {
    }

    internal static func CreateEdgeMesh(mesh: ProBuilderMesh, target: Mesh) {
    }

    internal static func CreateEdgeMesh(mesh: ProBuilderMesh, target: Mesh, edges: [Edge]) {
    }

    internal static func CreateVertexMesh(mesh: ProBuilderMesh, target: Mesh) {
    }

    internal static func CreateVertexMesh(mesh: ProBuilderMesh, target: Mesh, indexes: [Int]) {
    }

    static func CreatePointMesh(positions: [Vector3], indexes: [Int], target: Mesh) {
    }

    internal static func CreatePointBillboardMesh(positions: [Vector3], target: Mesh) {
    }

    static func CreatePointBillboardMesh(positions: [Vector3], indexes: [Int], target: Mesh) {
    }

    internal static func CreateEdgeBillboardMesh(mesh: ProBuilderMesh, target: Mesh) {
    }

    internal static func CreateEdgeBillboardMesh<T: Collection<Edge>>(mesh: ProBuilderMesh, target: Mesh, edges: T) {
    }


}
