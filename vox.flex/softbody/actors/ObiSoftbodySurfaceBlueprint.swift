//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class ObiSoftbodySurfaceBlueprint: ObiSoftbodyBlueprintBase {
    public struct ParticleType: OptionSet {
        public let rawValue: UInt32

        /// this initializer is required, but it's also automatically
        /// synthesized if `rawValue` is the only member, so writing it
        /// here is optional:
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let None = ParticleType([])
        public static let Bone = ParticleType(rawValue: 1 << 0)
        public static let Volume = ParticleType(rawValue: 1 << 1)
        public static let Surface = ParticleType(rawValue: 1 << 2)
        public static let All: ParticleType = [Bone, Volume, Surface]
    }

    public struct VoxelConnectivity: OptionSet {
        public let rawValue: UInt32

        /// this initializer is required, but it's also automatically
        /// synthesized if `rawValue` is the only member, so writing it
        /// here is optional:
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let None = VoxelConnectivity([])
        public static let Faces = VoxelConnectivity(rawValue: 1 << 0)
        public static let Edges = VoxelConnectivity(rawValue: 1 << 1)
        public static let Vertices = VoxelConnectivity(rawValue: 1 << 2)
        public static let All: VoxelConnectivity = [Faces, Edges, Vertices]
    }

    public enum SurfaceSamplingMode {
        case None
        case Vertices
        case Voxels
    }

    public enum VolumeSamplingMode {
        case None
        case Voxels
    }

    public enum SamplingMode {
        case Surface
        case Volume
        case Full
    }

    /// Method used to distribute particles on the surface of the mesh.
    public var surfaceSamplingMode = SurfaceSamplingMode.Voxels

    /// Resolution of the surface particle distribution.
    public var surfaceResolution = 16

    /// Method used to distribute particles on the volume of the mesh.
    public var volumeSamplingMode = VolumeSamplingMode.None

    /// Resolution of the volume particle distribution.
    public var volumeResolution = 16

    /// GameObject that contains the skeleton to sample.
    public var skeleton: Entity?

    /// Root bone of the skeleton.
    public var rootBone: Transform?

    /// Optional rotation applied to the skeleton.
    public var boneRotation: Quaternion?

    /// Maximum aspect ratio allowed for particles. High values will allow particles to deform more to better fit their neighborhood.
    public var maxAnisotropy: Float = 3

    /// Amount of smoothing applied to particle positions.
    public var smoothing: Float = 0.25

    /// Voxel resolution used to analyze the shape of the mesh.
    public var shapeResolution = 48

    public var generatedMesh: ModelMesh?
    public var vertexToParticle: [Int]?
    public var particleType: [ParticleType]?

    private var colorizer: GraphColoring?

    public struct ParticleToSurface {
        public var particleIndex: Int
        public var distance: Float

        public init(particleIndex: Int, distance: Float) {
            self.particleIndex = particleIndex
            self.distance = distance
        }
    }

    public static let DEFAULT_PARTICLE_MASS: Float = 0.1
    private var blueprintTransform = Matrix()

    private var m_DistanceField: VoxelDistanceField?
    private var m_PathFinder: VoxelPathFinder?
    private var voxelToParticles: [[Int]] = [[]]

    public private(set) var surfaceVoxelizer: MeshVoxelizer?
    public private(set) var volumeVoxelizer: MeshVoxelizer?
    public private(set) var shapeVoxelizer: MeshVoxelizer?

    func Initialize() {}

    private func ProjectOnMesh(point _: Vector3, vertices _: [Vector3], tris _: [Int]) -> Vector3 {
        Vector3()
    }

    private func VoxelizeForShapeAnalysis(boundsSize _: Vector3) {}

    private func VoxelizeForSurfaceSampling(boundsSize _: Vector3) {}

    private func VoxelizeForVolumeSampling(boundsSize _: Vector3) {}

    private func InsertParticlesIntoVoxels(voxelizer _: MeshVoxelizer, particles _: [Vector3]) {}

    private func VertexSampling(vertices _: [Vector3], particlePositions _: [Vector3]) {}

    private func VoxelSampling(voxelizer _: MeshVoxelizer, particles _: [Vector3],
                               voxelType _: MeshVoxelizer.Voxel, pType _: ParticleType) {}

    private func SkeletonSampling(boundsSize _: Vector3, particles _: [Vector3]) {}

    private func MapVerticesToParticles(vertices _: [Vector3], normals _: [Vector3],
                                        particlePositions _: [Vector3], particleNormals _: [Vector3]) {}

    private func GenerateParticles(particlePositions _: [Vector3], particleNormals _: [Vector3]) {}

    func SwapWithFirstInactiveParticle(index _: Int) {}

    func ConnectToNeighborParticles(voxelizer _: MeshVoxelizer, particle _: Int,
                                    particles _: [Vector3], allowed _: [ParticleType],
                                    x _: Int, y _: Int, z _: Int, neighborhood _: [Vector3Int],
                                    clusterSize _: Float, cluster _: [Int]) {}

    func CreateClustersFromVoxels(voxelizer _: MeshVoxelizer, particles _: Vector3,
                                  connectivity _: VoxelConnectivity, allowed _: [ParticleType]) {}

    func CreateClustersFromSkeleton(particles _: [Vector3]) {}

    func SurfaceMeshShapeMatchingConstraints(particles _: [Vector3], triangles _: [Int]) {}

    func CreateShapeMatchingConstraints(particles _: [Vector3]) {}
}
