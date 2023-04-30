//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Interface for the Oni particle physics library.
public class Oni {
    public let ConstraintTypeCount = 17

    public enum ConstraintType: Int {
        case Tether = 0
        case Volume = 1
        case Chain = 2
        case Bending = 3
        case Distance = 4
        case ShapeMatching = 5
        case BendTwist = 6
        case StretchShear = 7
        case Pin = 8
        case ParticleCollision = 9
        case Density = 10
        case Collision = 11
        case Skin = 12
        case Aerodynamics = 13
        case Stitch = 14
        case ParticleFriction = 15
        case Friction = 16
    }

    public enum ShapeType: Int {
        case Sphere = 0
        case Box = 1
        case Capsule = 2
        case Heightmap = 3
        case TriangleMesh = 4
        case EdgeMesh = 5
        case SignedDistanceField = 6
    }

    public enum MaterialCombineMode: Int {
        case Average = 0
        case Minimum = 1
        case Multiply = 2
        case Maximum = 3
    }

    public enum ProfileMask: UInt {
        case ThreadIdMask = 0xFFFF_0000
        case TypeMask = 0x0000_00FF
        case StackLevelMask = 0x0000_FF00
    }

    public struct GridCell {
        public var center: Vector3
        public var size: Vector3
        public var count: Int
    }

    public struct SolverParameters {
        public enum Interpolation {
            case None
            case Interpolate
        }

        public enum Mode {
            case Mode3D
            case Mode2D
        }

        /// In 2D mode, particles are simulated on the XY plane only. For use in conjunction with Unity's 2D mode.
        public var mode: Mode

        /// Same as Rigidbody.interpolation. Set to INTERPOLATE for cloth that is applied
        /// on a main character or closely followed by a camera. NONE for everything else.
        public var interpolation: Interpolation

        /// Simulation gravity expressed in local space.
        public var gravity: Vector3

        /// Percentage of velocity lost per second, between 0% (0) and 100% (1).
        public var damping: Float

        /// Max ratio between a particle's longest and shortest axis. Use 1 for isotropic (completely round) particles.
        public var maxAnisotropy: Float

        /// Mass-normalized kinetic energy threshold below which particle positions aren't updated.
        public var sleepThreshold: Float

        /// Maximum distance between elements (simplices/colliders) for a contact to be generated.
        public var collisionMargin: Float

        /// Maximum depenetration velocity applied to particles that start a frame inside an object.
        /// Low values ensure no 'explosive' collision resolution. Should be > 0 unless looking for non-physical effects.
        public var maxDepenetration: Float

        /// Percentage of particle velocities used for continuous collision detection.
        /// Set to 0 for purely static collisions, set to 1 for pure continuous collisions.
        public var continuousCollisionDetection: Float

        /// Percentage of shock propagation applied to particle-particle collisions. Useful for particle stacking.
        public var shockPropagation: Float

        /// Amount of iterations spent on convex optimization for surface collisions.
        public var surfaceCollisionIterations: Int

        /// Error threshold at which to stop convex optimization for surface collisions.
        public var surfaceCollisionTolerance: Float

        public init(interpolation: Interpolation, gravity: Vector4) {
            mode = Mode.Mode3D
            self.gravity = gravity.xyz
            self.interpolation = interpolation
            damping = 0
            shockPropagation = 0
            surfaceCollisionIterations = 8
            surfaceCollisionTolerance = 0.005
            maxAnisotropy = 3
            maxDepenetration = 10
            sleepThreshold = 0.0005
            collisionMargin = 0.02
            continuousCollisionDetection = 1
        }
    }

    public struct ConstraintParameters {
        public enum EvaluationOrder {
            case Sequential
            case Parallel
        }

        /// Order in which constraints are evaluated. SEQUENTIAL converges faster but is not very stable.
        /// PARALLEL is very stable but converges slowly, requiring more iterations to achieve the same result.
        public var evaluationOrder: EvaluationOrder

        /// Number of relaxation iterations performed by the constraint solver.
        /// A low number of iterations will perform better, but be less accurate.
        public var iterations: Int

        /// Over (or under if < 1) relaxation factor used. At 1, no overrelaxation is performed.
        /// At 2, constraints double their relaxation rate. High values reduce stability but improve convergence.
        public var SORFactor: Float

        /// Whether this constraint group is solved or not.
        public var enabled: Bool

        public init(enabled: Bool, order: EvaluationOrder, iterations: Int) {
            self.enabled = enabled
            self.iterations = iterations
            evaluationOrder = order
            SORFactor = 1
        }
    }

    /// In this particular case, size is forced to 144 bytes to ensure 16 byte memory alignment needed by Oni.
    public struct Contact {
        /// Speculative point of contact.
        public var pointA: Vector4
        public var pointB: Vector4
        /// Normal direction.
        public var normal: Vector4
        /// Tangent direction.
        public var tangent: Vector4
        /// Bitangent direction.
        public var bitangent: Vector4
        /// distance between both colliding entities at the beginning of the timestep.
        public var distance: Float

        public var normalImpulse: Float
        public var tangentImpulse: Float
        public var bitangentImpulse: Float
        public var stickImpulse: Float
        public var rollingFrictionImpulse: Float
        /// simplex index
        public var bodyA: Int
        /// simplex or rigidbody index
        public var bodyB: Int
    }
}
