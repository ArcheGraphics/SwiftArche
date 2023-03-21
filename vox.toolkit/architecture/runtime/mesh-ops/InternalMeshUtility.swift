//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

class InternalMeshUtility {
    /// Averages shared normals with the mask of all (indexes contained in perimeter edge)
    internal static func AverageNormalWithIndexes(shared: SharedVertex, all: [Int], norm: [Vector3]) -> Vector3 {
        Vector3()
    }

    /// "ProBuilder-ize" function
    public static func CreateMeshWithTransform(t: Transform, preserveFaces: Bool) -> ProBuilderMesh {
        let entity = Entity()
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// ProBuilderize in-place function. You must call ToMesh() and Refresh() after
    /// returning from this function, as this only creates the pb_Object and sets its
    /// fields. This allows you to record the mesh and gameObject for Undo operations.
    public static func ResetPbObjectWithMeshFilter(pb: ProBuilderMesh, preserveFaces: Bool) -> Bool {
        false
    }

    internal static func FilterUnusedSubmeshIndexes(mesh: ProBuilderMesh) {
    }
}
