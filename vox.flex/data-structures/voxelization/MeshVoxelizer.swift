//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Helper class that voxelizes a mesh.
public class MeshVoxelizer {
    public struct Voxel: OptionSet {
        public let rawValue: UInt32

        /// this initializer is required, but it's also automatically
        /// synthesized if `rawValue` is the only member, so writing it
        /// here is optional:
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let Empty = Voxel([])
        public static let Inside = Voxel(rawValue: 1 << 0)
        public static let Boundary = Voxel(rawValue: 1 << 1)
        public static let Outside = Voxel(rawValue: 1 << 2)
    }

    public static let fullNeighborhood: [Vector3Int] = [
        // face neighbors:
        Vector3Int(-1, 0, 0),
        Vector3Int(1, 0, 0),
        Vector3Int(0, -1, 0),
        Vector3Int(0, 1, 0),
        Vector3Int(0, 0, -1),
        Vector3Int(0, 0, 1),

        // edge neighbors:
        Vector3Int(-1, -1, 0),
        Vector3Int(-1, 0, -1),
        Vector3Int(-1, 0, 1),
        Vector3Int(-1, 1, 0),
        Vector3Int(0, -1, -1),
        Vector3Int(0, -1, 1),
        Vector3Int(0, 1, -1),
        Vector3Int(0, 1, 1),
        Vector3Int(1, -1, 0),
        Vector3Int(1, 0, -1),
        Vector3Int(1, 0, 1),
        Vector3Int(1, 1, 0),

        // vertex neighbors:
        Vector3Int(-1, -1, -1),
        Vector3Int(-1, -1, 1),
        Vector3Int(-1, 1, -1),
        Vector3Int(-1, 1, 1),
        Vector3Int(1, -1, -1),
        Vector3Int(1, -1, 1),
        Vector3Int(1, 1, -1),
        Vector3Int(1, 1, 1),
    ]

    public static let edgefaceNeighborhood: [Vector3Int] = [
        Vector3Int(-1, -1, 0),
        Vector3Int(-1, 0, -1),
        Vector3Int(-1, 0, 0),
        Vector3Int(-1, 0, 1),
        Vector3Int(-1, 1, 0),
        Vector3Int(0, -1, -1),
        Vector3Int(0, -1, 0),
        Vector3Int(0, -1, 1),
        Vector3Int(0, 0, -1),
        Vector3Int(0, 0, 1),
        Vector3Int(0, 1, -1),
        Vector3Int(0, 1, 0),
        Vector3Int(0, 1, 1),
        Vector3Int(1, -1, 0),
        Vector3Int(1, 0, -1),
        Vector3Int(1, 0, 0),
        Vector3Int(1, 0, 1),
        Vector3Int(1, 1, 0),
    ]

    public static let faceNeighborhood: [Vector3Int] = [
        Vector3Int(-1, 0, 0),
        Vector3Int(1, 0, 0),
        Vector3Int(0, -1, 0),
        Vector3Int(0, 1, 0),
        Vector3Int(0, 0, -1),
        Vector3Int(0, 0, 1),
    ]

    public static let edgeNeighborhood: [Vector3Int] = [
        Vector3Int(-1, -1, 0),
        Vector3Int(-1, 0, -1),
        Vector3Int(-1, 0, 1),
        Vector3Int(-1, 1, 0),
        Vector3Int(0, -1, -1),
        Vector3Int(0, -1, 1),
        Vector3Int(0, 1, -1),
        Vector3Int(0, 1, 1),
        Vector3Int(1, -1, 0),
        Vector3Int(1, 0, -1),
        Vector3Int(1, 0, 1),
        Vector3Int(1, 1, 0),
    ]

    public static let vertexNeighborhood: [Vector3Int] = [
        Vector3Int(-1, -1, -1),
        Vector3Int(-1, -1, 1),
        Vector3Int(-1, 1, -1),
        Vector3Int(-1, 1, 1),
        Vector3Int(1, -1, -1),
        Vector3Int(1, -1, 1),
        Vector3Int(1, 1, -1),
        Vector3Int(1, 1, 1),
    ]

    public var input: ModelMesh

    private var voxels: [Voxel] = []
    public var voxelSize: Float
    public var resolution: Vector3Int = .init(0, 0, 0)

    // temporary structure to hold triangles overlapping each voxel.
    private var triangleIndices: [[Int32]] = [[]]

    public private(set) var origin: Vector3Int = .init(0, 0, 0)

    public var voxelCount: Int32 { return resolution.x * resolution.y * resolution.z }

    public init(input: ModelMesh, voxelSize: Float) {
        self.input = input
        self.voxelSize = voxelSize
    }

    subscript(x: Int32, y: Int32, z: Int32) -> Voxel {
        get {
            voxels[Int(GetVoxelIndex(x, y, z))]
        }
        set {
            voxels[Int(GetVoxelIndex(x, y, z))] = newValue
        }
    }

    public func GetDistanceToNeighbor(at i: Int32) -> Float {
        if i > 17 { return ObiUtils.sqrt3 * voxelSize }
        if i > 5 { return ObiUtils.sqrt2 * voxelSize }
        return voxelSize
    }

    public func GetVoxelIndex(_ x: Int32, _ y: Int32, _ z: Int32) -> Int32 {
        return x + resolution.x * (y + resolution.y * z)
    }

    public func GetVoxelCenter(coords: Vector3Int) -> Vector3 {
        return Vector3(Float(origin.x + coords.x) + 0.5,
                       Float(origin.y + coords.y) + 0.5,
                       Float(origin.z + coords.z) + 0.5) * voxelSize
    }

    private func GetTriangleBounds(v1: Vector3, v2: Vector3, v3: Vector3) -> Bounds {
        Bounds.fromPoints(points: [v1, v2, v3])
    }

    public func GetTrianglesOverlappingVoxel(at voxelIndex: Int32) -> [Int32] {
        if voxelIndex >= 0, voxelIndex < triangleIndices.count {
            return triangleIndices[Int(voxelIndex)]
        }
        return []
    }

    public func GetPointVoxel(point: Vector3) -> Vector3Int {
        return Vector3Int(Int32(MathUtil.floorToInt(point.x / voxelSize)),
                          Int32(MathUtil.floorToInt(point.y / voxelSize)),
                          Int32(MathUtil.floorToInt(point.z / voxelSize)))
    }

    public func VoxelExists(coords: Vector3Int) -> Bool {
        return VoxelExists(x: coords.x, y: coords.y, z: coords.z)
    }

    public func VoxelExists(x: Int32, y: Int32, z: Int32) -> Bool {
        return x >= 0 && y >= 0 && z >= 0 &&
            x < resolution.x &&
            y < resolution.y &&
            z < resolution.z
    }

    private func AppendOverlappingVoxels(bounds _: Bounds, v1 _: Vector3, v2 _: Vector3, v3 _: Vector3, triangleIndex _: Int)
    {}

    public func Voxelize(transform _: Matrix, generateTriangleIndices _: Bool = false) {}

    public func BoundaryThinning() {}

    private func FloodFill() {}

    public static func IsIntersecting(box _: Bounds, v1 _: Vector3, v2 _: Vector3, v3 _: Vector3) -> Bool {
        false
    }

    static func TriangleAabbSATTest(v0 _: Vector3, v1 _: Vector3, v2 _: Vector3, aabbExtents _: Vector3, axis _: Vector3) -> Bool {
        false
    }
}
