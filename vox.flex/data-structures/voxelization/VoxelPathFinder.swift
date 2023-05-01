//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class VoxelPathFinder {
    private var voxelizer: MeshVoxelizer
    private var closed: [[[Bool]]]
    private var open: Queue<TargetVoxel> = Queue()

    public struct TargetVoxel {
        public var coordinates: Vector3Int
        public var distance: Float
        public var heuristic: Float

        public var cost: Float { return distance + heuristic }

        public init(coordinates: Vector3Int, distance: Float, heuristic: Float) {
            self.coordinates = coordinates
            self.distance = distance
            self.heuristic = heuristic
        }
    }

    public init(voxelizer: MeshVoxelizer) {
        self.voxelizer = voxelizer
        closed = [[[Bool]]](repeating: [[Bool]](repeating: [Bool](repeating: false,
                                                                  count: Int(voxelizer.resolution.x)),
                                                count: Int(voxelizer.resolution.y)),
                            count: Int(voxelizer.resolution.z))
    }

    private func AStar(start _: Vector3Int, termination _: (TargetVoxel) -> Bool,
                       heuristic _: (Vector3Int) -> Float) -> TargetVoxel
    {
        TargetVoxel(coordinates: Vector3Int.zero, distance: 0, heuristic: 0)
    }

    public func FindClosestNonEmptyVoxel(start _: Vector3Int) -> TargetVoxel {
        TargetVoxel(coordinates: Vector3Int.zero, distance: 0, heuristic: 0)
    }

    public func FindPath(start _: Vector3Int, end _: Vector3Int) -> TargetVoxel {
        TargetVoxel(coordinates: Vector3Int.zero, distance: 0, heuristic: 0)
    }
}
