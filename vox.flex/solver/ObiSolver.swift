//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// ObiSolver simulates particles and constraints, provided by a list of ObiActor. Particles belonging to different solvers won't interact with each other in any way.
public final class ObiSolver: Script {
    public enum BackendType {
        case Burst
    }

    var m_RigidbodyLinearVelocities: [Vector4] = []
    var m_RigidbodyAngularVelocities: [Vector4] = []

    // colors
    private lazy var m_Colors: [Color] = []

    // cell indices
    private lazy var m_CellCoords: [VInt4] = []

    // status:
    public private(set) lazy var activeParticles: [Int] = []
    private lazy var m_Simplices: [Int] = []

    // positions
    public private(set) lazy var positions: [Vector4] = []
    private lazy var m_RestPositions: [Vector4] = []
    private lazy var m_PrevPositions: [Vector4] = []
    private lazy var m_StartPositions: [Vector4] = []
    private lazy var m_RenderablePositions: [Vector4] = []

    // orientations
    private lazy var m_Orientations: [Quaternion] = []
    private lazy var m_RestOrientations: [Quaternion] = []
    private lazy var m_PrevOrientations: [Quaternion] = []
    private lazy var m_StartOrientations: [Quaternion] = []
    private lazy var m_RenderableOrientations: [Quaternion] = [] /** < renderable particle orientations. */

    // velocities
    private lazy var m_Velocities: [Vector4] = []
    private lazy var m_AngularVelocities: [Vector4] = []

    // masses/inertia tensors
    private lazy var m_InvMasses: [Float] = []
    private lazy var m_InvRotationalMasses: [Float] = []
    private lazy var m_InvInertiaTensors: [Vector4] = []

    // external forces
    private lazy var m_ExternalForces: [Vector4] = []
    private lazy var m_ExternalTorques: [Vector4] = []
    private lazy var m_Wind: [Vector4] = []

    // deltas
    private lazy var m_PositionDeltas: [Vector4] = []
    private lazy var m_OrientationDeltas: [Quaternion] = []
    private lazy var m_PositionConstraintCounts: [Int] = []
    private lazy var m_OrientationConstraintCounts: [Int] = []

    // particle collisions:
    private lazy var m_CollisionMaterials: [Int] = []
    private lazy var m_Phases: [Int] = []
    private lazy var m_Filters: [Int] = []

    // particle shape:
    private lazy var m_Anisotropies: [Vector4] = []
    private lazy var m_PrincipalRadii: [Vector4] = []
    private lazy var m_Normals: [Vector4] = []

    // fluids
    private lazy var m_Vorticities: [Vector4] = []
    private lazy var m_FluidData: [Vector4] = []
    private lazy var m_UserData: [Vector4] = []
    private lazy var m_SmoothingRadii: [Float] = []
    private lazy var m_Buoyancies: [Float] = []
    private lazy var m_RestDensities: [Float] = []
    private lazy var m_Viscosities: [Float] = []
    private lazy var m_SurfaceTension: [Float] = []
    private lazy var m_VortConfinement: [Float] = []
    private lazy var m_AtmosphericDrag: [Float] = []
    private lazy var m_AtmosphericPressure: [Float] = []
    private lazy var m_Diffusion: [Float] = []
}
