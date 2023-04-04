//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Methods for merging multiple <see cref="ProBuilderMesh"/> objects to a single mesh.
public enum CombineMeshes {
    /// Merge a collection of <see cref="ProBuilderMesh"/> objects to as few meshes as possible. It will re-use the meshTarget object as the first
    /// destination for the first <see cref="ProBuilderMesh.maxVertexCount"/> -1 vertices.
    /// If the sum of vertices is above <see cref="ProBuilderMesh.maxVertexCount"/> - 1
    /// it will generate new meshes unless there is a single mesh left in which case it will append it to the return list.
    /// - Parameters:
    ///   - meshes: A collection of meshes to be merged. Note: it is expected that meshes includes meshTarget.
    ///   - meshTarget: A mesh which will be used as the starting point for merging and which will be kept as reference/target.
    /// - Returns: A list of merged meshes. In most cases this will be a single mesh corresponding to meshTarget. However it can be multiple in cases
    /// where the resulting vertex count exceeds the maximum allowable value.
    public static func Combine<T: Sequence<ProBuilderMesh>>(meshes _: T, meshTarget _: ProBuilderMesh) -> [ProBuilderMesh] {
        []
    }

    static func CombineToNewMeshes<T: Sequence<ProBuilderMesh>>(meshes _: T) -> [ProBuilderMesh] {
        []
    }

    static func AccumulateMeshesInfo<T: Sequence<ProBuilderMesh>>(meshes _: T,
                                                                  offset _: Int,
                                                                  vertices _: inout [Vertex],
                                                                  faces _: inout [Face],
                                                                  autoUvFaces _: inout [Face],
                                                                  sharedVertices _: inout [SharedVertex],
                                                                  sharedTextures _: inout [SharedVertex],
                                                                  materialMap _: inout [Material],
                                                                  targetTransform _: Transform? = nil) {}

    static func CreateMeshFromSplit(vertices _: [Vertex],
                                    faces _: [Face],
                                    sharedVertexLookup _: [Int: Int],
                                    sharedTextureLookup _: [Int: Int],
                                    remap _: [Int: Int],
                                    materials _: [Material]) -> ProBuilderMesh
    {
        let entity = Entity()
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Break a ProBuilder mesh into multiple meshes if it's vertex count is greater than maxVertexCount.
    internal static func SplitByMaxVertexCount(vertices _: [Vertex], faces _: [Face],
                                               sharedVertices _: [SharedVertex], sharedTextures _: [SharedVertex],
                                               maxVertexCount _: UInt = UInt(ProBuilderMesh.maxVertexCount)) -> [ProBuilderMesh]
    {
        []
    }
}
