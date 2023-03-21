//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Methods for merging multiple <see cref="ProBuilderMesh"/> objects to a single mesh.
public class CombineMeshes {
    /// Merge a collection of <see cref="ProBuilderMesh"/> objects to as few meshes as possible. It will re-use the meshTarget object as the first
    /// destination for the first <see cref="ProBuilderMesh.maxVertexCount"/> -1 vertices.
    /// If the sum of vertices is above <see cref="ProBuilderMesh.maxVertexCount"/> - 1
    /// it will generate new meshes unless there is a single mesh left in which case it will append it to the return list.
    /// - Parameters:
    ///   - meshes: A collection of meshes to be merged. Note: it is expected that meshes includes meshTarget.
    ///   - meshTarget: A mesh which will be used as the starting point for merging and which will be kept as reference/target.
    /// - Returns: A list of merged meshes. In most cases this will be a single mesh corresponding to meshTarget. However it can be multiple in cases
    /// where the resulting vertex count exceeds the maximum allowable value.
    public static func Combine<T: Sequence<ProBuilderMesh>>(meshes: T, meshTarget: ProBuilderMesh) -> [ProBuilderMesh] {
        []
    }

    static func CombineToNewMeshes<T: Sequence<ProBuilderMesh>>(meshes: T) -> [ProBuilderMesh] {
        []
    }

    static func AccumulateMeshesInfo<T: Sequence<ProBuilderMesh>>(meshes: T,
                                                                  offset: Int,
                                                                  vertices: inout [Vertex],
                                                                  faces: inout [Face],
                                                                  autoUvFaces: inout [Face],
                                                                  sharedVertices: inout [SharedVertex],
                                                                  sharedTextures: inout [SharedVertex],
                                                                  materialMap: inout [Material],
                                                                  targetTransform: Transform? = nil) {
    }

    static func CreateMeshFromSplit(vertices: [Vertex],
                                    faces: [Face],
                                    sharedVertexLookup: [Int: Int],
                                    sharedTextureLookup: [Int: Int],
                                    remap: [Int: Int],
                                    materials: [Material]) -> ProBuilderMesh {
        let entity = Entity()
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Break a ProBuilder mesh into multiple meshes if it's vertex count is greater than maxVertexCount.
    internal static func SplitByMaxVertexCount(vertices: [Vertex], faces: [Face],
                                               sharedVertices: [SharedVertex], sharedTextures: [SharedVertex],
                                               maxVertexCount: UInt = UInt(ProBuilderMesh.maxVertexCount)) -> [ProBuilderMesh] {
        []
    }
}
