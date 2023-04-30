//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class BurstSolverImpl: ISolverImpl {
    var m_Solver: ObiSolver

    public var abstraction: ObiSolver { return m_Solver }

    public var particleCount: Int { return m_Solver.positions.count }

    public var activeParticleCount: Int { return abstraction.activeParticles.count }

    public var inertialFrame: BurstInertialFrame { return m_InertialFrame }

    public var solverToWorld: BurstAffineTransform { return m_InertialFrame.frame }

    public var worldToSolver: BurstAffineTransform { return m_InertialFrame.frame.Inverse() }

    public init(solver: ObiSolver) {
        m_Solver = solver

        // Initialize contact generation acceleration structure:
        particleGrid = ParticleGrid()

        // Initialize constraint batcher:
        collisionConstraintBatcher = ConstraintBatcher<ContactProvider>(maxBatches: maxBatches)
        fluidConstraintBatcher = ConstraintBatcher<FluidInteractionProvider>(maxBatches: maxBatches)

        // Initialize constraint arrays:
        constraints.reserveCapacity(Oni.ConstraintTypeCount)
    }

    public func Destroy() {}

    private let maxBatches = 17

    private var collisionConstraintBatcher: ConstraintBatcher<ContactProvider>
    private var fluidConstraintBatcher: ConstraintBatcher<FluidInteractionProvider>

    // Per-type constraints array:
    private var constraints: [IBurstConstraintsImpl] = []

    // Per-type iteration padding array:
    private var padding: [Int] = .init(repeating: 0, count: Oni.ConstraintTypeCount)

    // particle contact generation:
    public var particleGrid: ParticleGrid
//    public var particleContacts: BurstContact
    public lazy var particleBatchData: [BatchData] = []

    // fluid interaction generation:
    public lazy var fluidInteractions: [FluidInteraction] = []
    public lazy var fluidBatchData: [BatchData] = []

    // collider contact generation:
//    private var colliderGrid: BurstColliderWorld
    public lazy var colliderContacts: [BurstContact] = []

    // misc data:
    public lazy var activeParticles: [Int] = []
    private lazy var deformableTriangles: [Int] = .init(repeating: 0, count: 64)

    public lazy var simplices: [Int] = []
//    public var simplexCounts: SimplexCounts

    /// local to world inertial frame./
    private var m_InertialFrame: BurstInertialFrame!
    private var scheduledJobCounter = 0

    // cached particle data arrays (just wrappers over raw unmanaged data held by the abstract solver)
    public lazy var positions: [float4] = []
    public lazy var restPositions: [float4] = []
    public lazy var prevPositions: [float4] = []
    public lazy var renderablePositions: [float4] = []

    public lazy var orientations: [quaternion] = []
    public lazy var restOrientations: [quaternion] = []
    public lazy var prevOrientations: [quaternion] = []
    public lazy var renderableOrientations: [quaternion] = []

    public lazy var velocities: [float4] = []
    public lazy var angularVelocities: [float4] = []

    public lazy var invMasses: [Float] = []
    public lazy var invRotationalMasses: [Float] = []
    public lazy var invInertiaTensors: [float4] = []

    public lazy var externalForces: [float4] = []
    public lazy var externalTorques: [float4] = []
    public lazy var wind: [float4] = []

    public lazy var positionDeltas: [float4] = []
    public lazy var orientationDeltas: [quaternion] = []
    public lazy var positionConstraintCounts: [Int] = []
    public lazy var orientationConstraintCounts: [Int] = []

    public lazy var collisionMaterials: [Int] = []
    public lazy var phases: [Int] = []
    public lazy var filters: [Int] = []
    public lazy var anisotropies: [float4] = []
    public lazy var principalRadii: [float4] = []
    public lazy var normals: [float4] = []

    public lazy var vorticities: [float4] = []
    public lazy var fluidData: [float4] = []
    public lazy var userData: [float4] = []
    public lazy var smoothingRadii: [Float] = []
    public lazy var buoyancies: [Float] = []
    public lazy var restDensities: [Float] = []
    public lazy var viscosities: [Float] = []
    public lazy var surfaceTension: [Float] = []
    public lazy var vortConfinement: [Float] = []
    public lazy var athmosphericDrag: [Float] = []
    public lazy var athmosphericPressure: [Float] = []
    public lazy var diffusion: [Float] = []

    public lazy var cellCoords: [int4] = []
    public lazy var simplexBounds: [BurstAabb] = []

//    private var contactSorter: ConstraintSorter<BurstContact>

    public func InitializeFrame(translation: Vector4, scale: Vector4, rotation: Quaternion) {
        m_InertialFrame = BurstInertialFrame(position: translation.internalValue,
                                             scale: scale.internalValue,
                                             rotation: rotation.internalValue)
    }
}
