//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public enum RigidbodyInteractionType {
    case None
    case Kinematic
    case SimulatedDynamic
}

public enum StepHandlingMethod {
    case None
    case Standard
    case Extra
}

public enum MovementSweepState {
    case Initial
    case AfterFirstHit
    case FoundBlockingCrease
    case FoundBlockingCorner
}

/// Represents the entire state of a character motor that is pertinent for simulation.
/// Use this to save state or revert to past state
public struct KinematicCharacterMotorState {
    public var Position = Vector3()
    public var Rotation = Quaternion()
    public var BaseVelocity = Vector3()

    public var MustUnground: Bool = false
    public var MustUngroundTime: Float = 0
    public var LastMovementIterationFoundAnyGround: Bool = false
    public var GroundingStatus = CharacterTransientGroundingReport()

    public var AttachedRigidbody: DynamicCollider?
    public var AttachedRigidbodyVelocity = Vector3()
}

/// Describes an overlap between the character capsule and another collider
public struct OverlapResult {
    public var Normal = Vector3()
    public var Collider: Collider?
}

/// Contains all the information for the motor's grounding status
public struct CharacterGroundingReport {
    public var FoundAnyGround: Bool = false
    public var IsStableOnGround: Bool = false
    public var SnappingPrevented: Bool = false
    public var GroundNormal = Vector3()
    public var InnerGroundNormal = Vector3()
    public var OuterGroundNormal = Vector3()

    public var GroundCollider: Collider?
    public var GroundPoint = Vector3()

    public mutating func CopyFrom(transientGroundingReport: CharacterTransientGroundingReport) {
        FoundAnyGround = transientGroundingReport.FoundAnyGround
        IsStableOnGround = transientGroundingReport.IsStableOnGround
        SnappingPrevented = transientGroundingReport.SnappingPrevented
        GroundNormal = transientGroundingReport.GroundNormal
        InnerGroundNormal = transientGroundingReport.InnerGroundNormal
        OuterGroundNormal = transientGroundingReport.OuterGroundNormal

        GroundCollider = nil
        GroundPoint = Vector3()
    }
}

/// Contains the simulation-relevant information for the motor's grounding status
public struct CharacterTransientGroundingReport {
    public var FoundAnyGround: Bool = false
    public var IsStableOnGround: Bool = false
    public var SnappingPrevented: Bool = false
    public var GroundNormal = Vector3()
    public var InnerGroundNormal = Vector3()
    public var OuterGroundNormal = Vector3()

    public mutating func CopyFrom(groundingReport: CharacterGroundingReport) {
        FoundAnyGround = groundingReport.FoundAnyGround
        IsStableOnGround = groundingReport.IsStableOnGround
        SnappingPrevented = groundingReport.SnappingPrevented
        GroundNormal = groundingReport.GroundNormal
        InnerGroundNormal = groundingReport.InnerGroundNormal
        OuterGroundNormal = groundingReport.OuterGroundNormal
    }
}

/// Contains all the information from a hit stability evaluation
public struct HitStabilityReport {
    public var IsStable: Bool = false

    public var FoundInnerNormal: Bool = false
    public var InnerNormal = Vector3()
    public var FoundOuterNormal: Bool = false
    public var OuterNormal = Vector3()

    public var ValidStepDetected: Bool = false
    public var SteppedCollider: Collider

    public var LedgeDetected: Bool = false
    public var IsOnEmptySideOfLedge: Bool = false
    public var DistanceFromLedge: Float = 0
    public var IsMovingTowardsEmptySideOfLedge: Bool = false
    public var LedgeGroundNormal = Vector3()
    public var LedgeRightDirection = Vector3()
    public var LedgeFacingDirection = Vector3()
}

/// Contains the information of hit rigidbodies during the movement phase, so they can be processed afterwards
public struct RigidbodyProjectionHit {
    public var Rigidbody: DynamicCollider?
    public var HitPoint = Vector3()
    public var EffectiveHitNormal = Vector3()
    public var HitVelocity = Vector3()
    public var StableOnHit: Bool = false
}

/// Component that manages character collisions and movement solving
public class KinematicCharacterMotor: Script {
    //MARK: - Components
    /// The capsule collider of this motor
    public var Capsule: DynamicCollider?

    //MARK: - Capsule Settings

    /// Radius of the character's capsule
    private var CapsuleRadius: Float = 0.5

    /// Height of the character's capsule
    private var CapsuleHeight: Float = 2

    /// Local y position of the character's capsule center
    private var CapsuleYOffset: Float = 1

    /// Physics material of the character's capsule
    private var CapsulePhysicsMaterial: PhysicsMaterial?

    //MARK: - Grounding settings

    /// Increases the range of ground detection, to allow snapping to ground at very high speeds
    public var GroundDetectionExtraDistance: Float = 0

    /// Maximum slope angle on which the character can be stable
    public var MaxStableSlopeAngle: Float = 60

    /// Which layers can the character be considered stable on
    public var StableGroundLayers: Layer = []

    /// Notifies the Character Controller when discrete collisions are detected
    public var DiscreteCollisionEvents = false


    //MARK: - Step settings

    /// Handles properly detecting grounding status on steps, but has a performance cost.
    public var StepHandling = StepHandlingMethod.Standard

    /// Maximum height of a step which the character can climb
    public var MaxStepHeight: Float = 0.5

    /// Can the character step up obstacles even if it is not currently stable?
    public var AllowSteppingWithoutStableGrounding = false

    /// Minimum length of a step that the character can step on (used in Extra stepping method. Use this to let the character step on steps that are smaller that its radius
    public var MinRequiredStepDepth: Float = 0.1


    //MARK: - Ledge settings

    /// Handles properly detecting ledge information and grounding status, but has a performance cost.
    public var LedgeAndDenivelationHandling: Bool = true

    /// The distance from the capsule central axis at which the character can stand on a ledge and still be stable
    public var MaxStableDistanceFromLedge: Float = 0.5

    /// Prevents snapping to ground on ledges beyond a certain velocity
    public var MaxVelocityForLedgeSnap: Float = 0

    /// The maximun downward slope angle change that the character can be subjected to and still be snapping to the ground
    public var MaxStableDenivelationAngle: Float = 180


    //MARK: - Rigidbody interaction settings

    /// Handles properly being pushed by and standing on PhysicsMovers or dynamic rigidbodies. Also handles pushing dynamic rigidbodies
    public var InteractiveRigidbodyHandling = true

    /// How the character interacts with non-kinematic rigidbodies.
    /// \"Kinematic\" mode means the character pushes the rigidbodies with infinite force (as a kinematic body would).
    /// \"SimulatedDynamic\" pushes the rigidbodies with a simulated mass value.
    public var RigidbodyInteractionType: RigidbodyInteractionType = .None

    public var SimulatedCharacterMass: Float = 1

    /// Determines if the character preserves moving platform velocities when de-grounding from them
    public var PreserveAttachedRigidbodyMomentum = true


    //MARK: - Constraints settings

    /// Determines if the character's movement uses the planar constraint
    public var HasPlanarConstraint = false

    /// Defines the plane that the character's movement is constrained on, if HasMovementConstraintPlane is active
    public var PlanarConstraintAxis = Vector3.forward

    //MARK: - Other settings

    /// How many times can we sweep for movement per update
    public var MaxMovementIterations = 5

    /// How many times can we check for decollision per update
    public var MaxDecollisionIterations = 1

    /// Checks for overlaps before casting movement, making sure all collisions are detected even when already intersecting geometry
    /// (has a performance cost, but provides safety against tunneling through colliders)
    public var CheckMovementInitialOverlaps = true

    /// Sets the velocity to zero if exceed max movement iterations
    public var KillVelocityWhenExceedMaxMovementIterations = true

    /// Sets the remaining movement to zero if exceed max movement iterations
    public var KillRemainingMovementWhenExceedMaxMovementIterations = true


    /// Contains the current grounding information
    public var GroundingStatus = CharacterGroundingReport()

    /// Contains the previous grounding information
    public var LastGroundingStatus = CharacterTransientGroundingReport()

    /// Specifies the LayerMask that the character's movement algorithm can detect collisions with. By default, this uses the rigidbody's layer's collision matrix
    public var CollidableLayers: Layer = []


    /// The Transform of the character motor

    public var Transform: Transform? {
        get {
            return _transform
        }
    }
    private var _transform: Transform?

    /// The character's goal position in its movement calculations (always up-to-date during the character update phase)
    public var TransientPosition: Vector3 {
        get {
            return _transientPosition
        }
    }
    private var _transientPosition = Vector3()

    /// The character's up direction (always up-to-date during the character update phase)
    public var CharacterUp: Vector3 {
        get {
            return _characterUp
        }
    }
    private var _characterUp = Vector3()

    /// The character's forward direction (always up-to-date during the character update phase)
    public var CharacterForward: Vector3 {
        get {
            return _characterForward
        }
    }
    private var _characterForward = Vector3()

    /// The character's right direction (always up-to-date during the character update phase)
    public var CharacterRight: Vector3 {
        get {
            return _characterRight
        }
    }
    private var _characterRight = Vector3()

    /// The character's position before the movement calculations began
    public var InitialSimulationPosition: Vector3 {
        get {
            return _initialSimulationPosition
        }
    }
    private var _initialSimulationPosition = Vector3()

    /// The character's rotation before the movement calculations began
    public var InitialSimulationRotation: Quaternion {
        get {
            return _initialSimulationRotation
        }
    }
    private var _initialSimulationRotation = Quaternion()

    /// Represents the Rigidbody to stay attached to
    public var AttachedRigidbody: DynamicCollider? {
        get {
            return _attachedRigidbody
        }
    }
    private var _attachedRigidbody: DynamicCollider?

    /// Vector3 from the character transform position to the capsule center
    public var CharacterTransformToCapsuleCenter: Vector3 {
        get {
            return _characterTransformToCapsuleCenter
        }
    }
    private var _characterTransformToCapsuleCenter = Vector3()

    /// Vector3 from the character transform position to the capsule bottom
    public var CharacterTransformToCapsuleBottom: Vector3 {
        get {
            return _characterTransformToCapsuleBottom
        }
    }
    private var _characterTransformToCapsuleBottom = Vector3()

    /// Vector3 from the character transform position to the capsule top
    public var CharacterTransformToCapsuleTop: Vector3 {
        get {
            return _characterTransformToCapsuleTop
        }
    }
    private var _characterTransformToCapsuleTop = Vector3()

    /// Vector3 from the character transform position to the capsule bottom hemi center
    public var CharacterTransformToCapsuleBottomHemi: Vector3 {
        get {
            return _characterTransformToCapsuleBottomHemi
        }
    }
    private var _characterTransformToCapsuleBottomHemi = Vector3()

    /// Vector3 from the character transform position to the capsule top hemi center
    public var CharacterTransformToCapsuleTopHemi: Vector3 {
        get {
            return _characterTransformToCapsuleTopHemi
        }
    }
    private var _characterTransformToCapsuleTopHemi = Vector3()

    /// The character's velocity resulting from standing on rigidbodies or PhysicsMover
    public var AttachedRigidbodyVelocity: Vector3 {
        get {
            return _attachedRigidbodyVelocity
        }
    }
    private var _attachedRigidbodyVelocity = Vector3()

    /// The number of overlaps detected so far during character update (is reset at the beginning of the update)
    public var OverlapsCount: Int {
        get {
            return _overlapsCount
        }
    }
    private var _overlapsCount: Int = 0

    /// The overlaps detected so far during character update
    public var Overlaps: [OverlapResult] {
        get {
            return _overlaps
        }
    }
    private var _overlaps = [OverlapResult](repeating: OverlapResult(), count: MaxRigidbodyOverlapsCount)

    /// The motor's assigned controller
    public var CharacterController: ICharacterController?

    /// Did the motor's last swept collision detection find a ground?
    public var LastMovementIterationFoundAnyGround: Bool = false

    /// Index of this motor in KinematicCharacterSystem arrays
    public var IndexInCharacterSystem: Int = 0

    /// Remembers initial position before all simulation are done
    public var InitialTickPosition = Vector3()

    /// Remembers initial rotation before all simulation are done
    public var InitialTickRotation = Quaternion()

    /// Specifies a Rigidbody to stay attached to
    public var AttachedRigidbodyOverride: DynamicCollider?

    /// The character's velocity resulting from direct movement
    public var BaseVelocity = Vector3()

    // Private
    private var _internalCharacterHits = [HitResult](repeating: HitResult(), count: MaxHitsBudget)
    private var _internalProbedColliders = [Collider?](repeating: nil, count: MaxCollisionBudget)
    private var _rigidbodiesPushedThisMove = [DynamicCollider?](repeating: nil, count: 16)
    private var _internalRigidbodyProjectionHits = [RigidbodyProjectionHit](repeating: RigidbodyProjectionHit(),
            count: MaxRigidbodyOverlapsCount)
    private var _lastAttachedRigidbody: DynamicCollider?
    private var _solveMovementCollisions = true
    private var _solveGrounding = true
    private var _movePositionDirty = false
    private var _movePositionTarget = Vector3()
    private var _moveRotationDirty = false
    private var _moveRotationTarget = Quaternion()
    private var _lastSolvedOverlapNormalDirty = false
    private var _lastSolvedOverlapNormal = Vector3.forward
    private var _rigidbodyProjectionHitCount = 0
    private var _isMovingFromAttachedRigidbody = false
    private var _mustUnground = false
    private var _mustUngroundTimeCounter: Float = 0
    private var _cachedWorldUp = Vector3.up
    private var _cachedWorldForward = Vector3.forward
    private var _cachedWorldRight = Vector3.right
    private var _cachedZeroVector = Vector3()

    /// The character's goal rotation in its movement calculations (always up-to-date during the character update phase)
    public var TransientRotation: Quaternion {
        get {
            return _transientRotation
        }
        set {
            _transientRotation = newValue
            _characterUp = Vector3.transformByQuat(v: _cachedWorldUp, quaternion: _transientRotation)
            _characterForward = Vector3.transformByQuat(v: _cachedWorldForward, quaternion: _transientRotation)
            _characterRight = Vector3.transformByQuat(v: _cachedWorldRight, quaternion: _transientRotation)
        }
    }
    private var _transientRotation = Quaternion()

    /// The character's total velocity, including velocity from standing on rigidbodies or PhysicsMover
    public var Velocity: Vector3 {
        get {
            BaseVelocity + _attachedRigidbodyVelocity
        }
    }

    // Warning: Don't touch these constants unless you know exactly what you're doing!
    public static let MaxHitsBudget: Int = 16
    public static let MaxCollisionBudget: Int = 16
    public static let MaxGroundingSweepIterations: Int = 2
    public static let MaxSteppingSweepIterations: Int = 3
    public static let MaxRigidbodyOverlapsCount: Int = 16
    public static let CollisionOffset: Float = 0.01
    public static let GroundProbeReboundDistance: Float = 0.02
    public static let MinimumGroundProbingDistance: Float = 0.005
    public static let GroundProbingBackstepDistance: Float = 0.1
    public static let SweepProbingBackstepDistance: Float = 0.002
    public static let SecondaryProbesVertical: Float = 0.02
    public static let SecondaryProbesHorizontal: Float = 0.001
    public static let MinVelocityMagnitude: Float = 0.01
    public static let SteppingForwardDistance: Float = 0.03
    public static let MinDistanceForLedge: Float = 0.05
    public static let CorrelationForVerticalObstruction: Float = 0.01
    public static let ExtraSteppingForwardDistance: Float = 0.01
    public static let ExtraStepHeightPadding: Float = 0.01
}
