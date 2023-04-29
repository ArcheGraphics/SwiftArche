//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Generates a sparse distance field from a voxel representation of a mesh.
public class VoxelDistanceField {
    /// for each coordinate, stores coordinates of closest surface voxel./
    public var distanceField: [[[Vector3Int]]] = [[[]]]

    private var voxelizer: MeshVoxelizer

    public init(voxelizer: MeshVoxelizer) {
        self.voxelizer = voxelizer
    }

    public func SampleUnfiltered(x _: Int, y _: Int, z _: Int) -> Float {
        0
    }

    public func SampleFiltered(x _: Float, y _: Float, z _: Float) -> Vector4 {
        Vector4()
    }

    public func JumpFlood() {}
    
    private func JumpFloodPass(stride _: Int, input _: [[[Vector3Int]]], output _: [[[Vector3Int]]]) {}
}
