//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiActorBlueprint: IObiParticleCollection {
    var m_Empty: Bool = true
    var m_ActiveParticleCount = 0
    var m_InitialActiveParticleCount = 0
    var _bounds: Bounds = .init()

    /** Particle components */
    /// Particle positions.
    public lazy var positions: [Vector3] = []
    /// Particle rest positions, used to filter collisions.
    public lazy var restPositions: [Vector4] = []

    /// Particle orientations.
    public lazy var orientations: [Quaternion] = []
    /// Particle rest orientations.
    public lazy var restOrientations: [Quaternion] = []

    /// Particle velocities.
    public lazy var velocities: [Vector3] = []
    /// Particle angular velocities.
    public lazy var angularVelocities: [Vector3] = []

    /// Particle inverse masses
    public lazy var invMasses: [Float] = []
    public lazy var invRotationalMasses: [Float] = []

    /// Particle filters
    public lazy var filters: [Int] = []
    /// Particle ellipsoid principal radii. These are the ellipsoid radius in each axis.
    public lazy var principalRadii: [Vector3] = []
    /// Particle colors (not used by all actors, can be null)
    public lazy var colors: [Color] = []

    /** Simplices **/
    public lazy var points: [Int] = []
    public lazy var edges: [Int] = []
    public lazy var triangles: [Int] = []

    /** Constraint components. Each constraint type contains a list of constraint batches. */
    public var distanceConstraintsData: ObiDistanceConstraintsData? = nil
    public var bendConstraintsData: ObiBendConstraintsData? = nil
    public var skinConstraintsData: ObiSkinConstraintsData? = nil
    public var tetherConstraintsData: ObiTetherConstraintsData? = nil
    public var stretchShearConstraintsData: ObiStretchShearConstraintsData? = nil
    public var bendTwistConstraintsData: ObiBendTwistConstraintsData? = nil
    public var shapeMatchingConstraintsData: ObiShapeMatchingConstraintsData? = nil
    public var aerodynamicConstraintsData: ObiAerodynamicConstraintsData? = nil
    public var chainConstraintsData: ObiChainConstraintsData? = nil
    public var volumeConstraintsData: ObiVolumeConstraintsData? = nil

    /** Particle groups. */
    public var groups: [ObiParticleGroup] = []

    public var particleCount: Int = 0

    public var activeParticleCount: Int = 0

    public var usesOrientedParticles: Bool = false

    public func GetParticleRuntimeIndex(at _: Int) -> Int {
        0
    }

    public func GetParticlePosition(at _: Int) -> Vector3 {
        Vector3()
    }

    public func GetParticleOrientation(at _: Int) -> Quaternion {
        Quaternion()
    }

    public func GetParticleAnisotropy(at _: Int, b1 _: inout Vector4, b2 _: inout Vector4, b3 _: inout Vector4) {}

    public func GetParticleMaxRadius(at _: Int) -> Float {
        0
    }

    public func GetParticleColor(at _: Int) -> Color {
        Color()
    }
}
