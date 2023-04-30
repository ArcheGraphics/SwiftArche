//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public struct MovingEntity {
    public var oldCellCoord: int4
    public var newCellCoord: int4
    public var entity: Int
}

public class ParticleGrid {
    public var grid: NativeMultilevelGrid<Int>
    public var particleContactQueue: Queue<BurstContact> = Queue()
    public var fluidInteractionQueue: Queue<FluidInteraction> = Queue()

    struct CalculateCellCoords {
        public private(set) var simplexBounds: [BurstAabb]
        public var cellCoords: [int4]
        public var is2D: Bool

        public func Execute(i _: Int) {}
    }

    struct UpdateGrid {
        public var grid: [Int]
        public private(set) var cellCoords: [int4]
        public private(set) var simplexCount: Int

        public func Execute() {}
    }

    public struct GenerateParticleParticleContactsJob {
        public private(set) var grid: NativeMultilevelGrid<Int>
        public private(set) var gridLevels: [Int]

        public private(set) var positions: [float4]
        public private(set) var orientations: [quaternion]
        public private(set) var restPositions: [float4]
        public private(set) var restOrientations: [quaternion]
        public private(set) var velocities: [float4]
        public private(set) var invMasses: [Float]
        public private(set) var radii: [float4]
        public private(set) var normals: [float4]
        public private(set) var fluidRadii: [Float]
        public private(set) var phases: [Int]
        public private(set) var filters: [Int]

        // simplex arrays:
        public private(set) var simplices: [Int]
        public private(set) var simplexCounts: SimplexCounts
        public private(set) var simplexBounds: [BurstAabb]

        public private(set) var particleMaterialIndices: [Int]
        public private(set) var collisionMaterials: [CollisionMaterial]

        public var contactsQueue: [BurstContact]

        public var fluidInteractionsQueue: [FluidInteraction]

        public private(set) var dt: Float
        public private(set) var collisionMargin: Float
        public private(set) var optimizationIterations: Int
        public private(set) var optimizationTolerance: Float

        public func Execute(i _: Int) {}

        private func IntraCellSearch(at _: Int, simplexShape _: BurstSimplex) {}

        private func InterCellSearch(at _: Int, neighborCellIndex _: Int, simplexShape _: BurstSimplex) {}

        private func IntraLevelSearch(at _: Int, simplexShape _: BurstSimplex) {}

        private func GetSimplexGroup(simplexStart _: Int, simplexSize _: Int, flags _: inout ObiUtils.ParticleFlags,
                                     category _: inout Int, mask _: inout Int, restPositionsEnabled _: Bool) -> Int
        {
            0
        }

        private func InteractionTest(A _: Int, B _: Int, simplexShape _: BurstSimplex) {}
    }

    public struct InterpolateDiffusePropertiesJob {
        public private(set) var grid: NativeMultilevelGrid<Int>

        public private(set) var cellOffsets: [int4]

        public private(set) var positions: [float4]
        public private(set) var properties: [float4]
        public private(set) var diffusePositions: [float4]
        public private(set) var densityKernel: Poly6Kernel

        public var diffuseProperties: [float4]
        public var neighbourCount: [Int]

        public private(set) var gridLevels: [Int]

        public private(set) var inertialFrame: BurstInertialFrame
        public private(set) var mode2D: Bool

        public func Execute(p _: Int) {}
    }

    public init() {
        grid = NativeMultilevelGrid(capacity: 100)
    }

    public func Update(solver _: BurstSolverImpl, deltaTime _: Float) {}

    public func GenerateContacts(solver _: BurstSolverImpl, deltaTime _: Float) {}

    public func InterpolateDiffuseProperties(solver _: BurstSolverImpl,
                                             properties _: [float4],
                                             diffusePositions _: [float4],
                                             diffuseProperties _: [float4],
                                             neighbourCount _: [Int],
                                             diffuseCount _: Int) {}

    public func SpatialQuery(solver _: BurstSolverImpl,
                             shapes _: [BurstQueryShape],
                             transforms _: [BurstAffineTransform],
                             results _: [BurstQueryResult]) {}

    public func GetCells(cells _: [Aabb]) {}
}
