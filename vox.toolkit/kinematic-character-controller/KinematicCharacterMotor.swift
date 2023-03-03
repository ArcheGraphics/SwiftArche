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
    public var SteppedCollider: Collider?

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
    private var CapsulePhysicsMaterial = PhysicsMaterial()

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
    public var rigidbodyInteractionType: RigidbodyInteractionType = .None

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

    public var Transform: Transform {
        get {
            return _transform
        }
    }
    private var _transform: Transform!

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

    public override func onEnable() {
        KinematicCharacterSystem.instance.RegisterCharacterMotor(self)
    }

    public override func onDisable() {
        KinematicCharacterSystem.instance.UnregisterCharacterMotor(self)
    }

    public override func onAwake() {
        _transform = entity.transform
        ValidateData()

        _transientPosition = _transform.position
        TransientRotation = _transform.rotationQuaternion

        // Build CollidableLayers mask
        CollidableLayers = []
        for i: UInt16 in 0..<32 {
            if (!engine.physicsManager.getIgnoreLayerCollision(group1: UInt16(entity.layer.rawValue.nonzeroBitCount), group2: i)) {
                CollidableLayers.insert(Layer(rawValue: 1 << i))
            }
        }

        SetCapsuleDimensions(radius: CapsuleRadius, height: CapsuleHeight, yOffset: CapsuleYOffset)
    }
}

extension KinematicCharacterMotor {
    /// Handle validating all required values
    public func ValidateData() {
        Capsule = entity.getComponent(DynamicCollider.self)
        CapsuleRadius = simd_clamp(CapsuleRadius, 0, CapsuleHeight * 0.5)
        if let Capsule = Capsule {
            let shape = Capsule.shapes[0] as! CapsuleColliderShape
            shape.upAxis = .Y
            shape.material = CapsulePhysicsMaterial
        }
        SetCapsuleDimensions(radius: CapsuleRadius, height: CapsuleHeight, yOffset: CapsuleYOffset)

        MaxStepHeight = simd_clamp(MaxStepHeight, 0, Float.infinity)
        MinRequiredStepDepth = simd_clamp(MinRequiredStepDepth, 0, CapsuleRadius)
        MaxStableDistanceFromLedge = simd_clamp(MaxStableDistanceFromLedge, 0, CapsuleRadius)

        entity.transform.scale = Vector3.one
    }

    /// Sets whether or not the capsule collider will detect collisions
    public func SetCapsuleCollisionsActivation(_ collisionsActive: Bool) {
        Capsule!.shapes[0].isTrigger = !collisionsActive
    }

    /// Sets whether or not the motor will solve collisions when moving (or moved onto)
    public func SetMovementCollisionsSolvingActivation(_ movementCollisionsSolvingActive: Bool) {
        _solveMovementCollisions = movementCollisionsSolvingActive
    }

    /// Sets whether or not grounding will be evaluated for all hits
    public func SetGroundSolvingActivation(_ stabilitySolvingActive: Bool) {
        _solveGrounding = stabilitySolvingActive
    }

    /// Sets the character's position directly
    public func SetPosition(_ position: Vector3, bypassInterpolation: Bool = true) {
        _transform.position = position
        _initialSimulationPosition = position
        _transientPosition = position

        if (bypassInterpolation) {
            InitialTickPosition = position
        }
    }

    /// Sets the character's rotation directly
    public func SetRotation(_ rotation: Quaternion, bypassInterpolation: Bool = true) {
        _transform.rotationQuaternion = rotation
        _initialSimulationRotation = rotation
        TransientRotation = rotation

        if (bypassInterpolation) {
            InitialTickRotation = rotation
        }
    }

    /// Sets the character's position and rotation directly
    public func SetPositionAndRotation(_ position: Vector3, _ rotation: Quaternion, bypassInterpolation: Bool = true) {
        _transform.position = position
        _transform.rotationQuaternion = rotation
        _initialSimulationPosition = position
        _initialSimulationRotation = rotation
        _transientPosition = position
        TransientRotation = rotation

        if (bypassInterpolation) {
            InitialTickPosition = position
            InitialTickRotation = rotation
        }
    }

    /// Moves the character position, taking all movement collision solving int account. The actual move is done the next time the motor updates are called
    public func MoveCharacter(to: Vector3) {
        _movePositionDirty = true
        _movePositionTarget = to
    }

    /// Moves the character rotation. The actual move is done the next time the motor updates are called
    public func RotateCharacter(to: Quaternion) {
        _moveRotationDirty = true
        _moveRotationTarget = to
    }

    /// Returns all the state information of the motor that is pertinent for simulation
    public func GetState() -> KinematicCharacterMotorState {
        var state = KinematicCharacterMotorState()

        state.Position = _transientPosition
        state.Rotation = _transientRotation

        state.BaseVelocity = BaseVelocity
        state.AttachedRigidbodyVelocity = _attachedRigidbodyVelocity

        state.MustUnground = _mustUnground
        state.MustUngroundTime = _mustUngroundTimeCounter
        state.LastMovementIterationFoundAnyGround = LastMovementIterationFoundAnyGround
        state.GroundingStatus.CopyFrom(groundingReport: GroundingStatus)
        state.AttachedRigidbody = _attachedRigidbody

        return state
    }

    /// Applies a motor state instantly
    public func ApplyState(_ state: KinematicCharacterMotorState, bypassInterpolation: Bool = true) {
        SetPositionAndRotation(state.Position, state.Rotation, bypassInterpolation: bypassInterpolation)

        BaseVelocity = state.BaseVelocity
        _attachedRigidbodyVelocity = state.AttachedRigidbodyVelocity

        _mustUnground = state.MustUnground
        _mustUngroundTimeCounter = state.MustUngroundTime
        LastMovementIterationFoundAnyGround = state.LastMovementIterationFoundAnyGround
        GroundingStatus.CopyFrom(transientGroundingReport: state.GroundingStatus)
        _attachedRigidbody = state.AttachedRigidbody
    }

    /// Resizes capsule. ALso caches importand capsule size data
    public func SetCapsuleDimensions(radius: Float, height: Float, yOffset: Float) {
        let height = max(height, (radius * 2) + 0.01) // Safety to prevent invalid capsule geometries

        CapsuleRadius = radius
        CapsuleHeight = height
        CapsuleYOffset = yOffset

        if let CapsuleShape = Capsule!.shapes[0] as? CapsuleColliderShape {
            CapsuleShape.radius = CapsuleRadius
            CapsuleShape.height = simd_clamp(CapsuleHeight, CapsuleRadius * 2, CapsuleHeight)
            CapsuleShape.position = Vector3(0, CapsuleYOffset, 0)

            _characterTransformToCapsuleCenter = CapsuleShape.position
            _characterTransformToCapsuleBottom = CapsuleShape.position + (-_cachedWorldUp * (CapsuleShape.height * 0.5))
            _characterTransformToCapsuleTop = CapsuleShape.position + (_cachedWorldUp * (CapsuleShape.height * 0.5))
            _characterTransformToCapsuleBottomHemi = CapsuleShape.position + (-_cachedWorldUp * (CapsuleShape.height * 0.5)) + (_cachedWorldUp * CapsuleShape.radius)
            _characterTransformToCapsuleTopHemi = CapsuleShape.position + (_cachedWorldUp * (CapsuleShape.height * 0.5)) + (-_cachedWorldUp * CapsuleShape.radius)
        }
    }

    /// Update phase 1 is meant to be called after physics movers have calculated their velocities, but
    /// before they have simulated their goal positions/rotations. It is responsible for:
    /// - Initializing all values for update
    /// - Handling MovePosition calls
    /// - Solving initial collision overlaps
    /// - Ground probing
    /// - Handle detecting potential interactable rigidbodies
    public func UpdatePhase1(deltaTime: Float) {
        // NaN propagation safety stop
        if (BaseVelocity.x.isNaN || BaseVelocity.y.isNaN || BaseVelocity.z.isNaN) {
            BaseVelocity = Vector3.zero
        }
        if (_attachedRigidbodyVelocity.x.isNaN || _attachedRigidbodyVelocity.y.isNaN || _attachedRigidbodyVelocity.z.isNaN) {
            _attachedRigidbodyVelocity = Vector3.zero
        }

        _rigidbodiesPushedThisMove = []

        // Before update
        CharacterController!.BeforeCharacterUpdate(deltaTime: deltaTime)

        _transientPosition = _transform.position
        TransientRotation = _transform.rotationQuaternion
        _initialSimulationPosition = _transientPosition
        _initialSimulationRotation = _transientRotation
        _rigidbodyProjectionHitCount = 0
        _overlapsCount = 0
        _lastSolvedOverlapNormalDirty = false

        // MARK: - Handle Move Position
        if (_movePositionDirty) {
            if (_solveMovementCollisions) {
                var tmpVelocity = GetVelocityFromMovement(movement: _movePositionTarget - _transientPosition, deltaTime: deltaTime)
                if (InternalCharacterMove(transientVelocity: &tmpVelocity, deltaTime: deltaTime)) {
                    if (InteractiveRigidbodyHandling) {
                        ProcessVelocityForRigidbodyHits(processedVelocity: &tmpVelocity, deltaTime: deltaTime)
                    }
                }
            } else {
                _transientPosition = _movePositionTarget
            }

            _movePositionDirty = false
        }

        LastGroundingStatus.CopyFrom(groundingReport: GroundingStatus)
        GroundingStatus = CharacterGroundingReport()
        GroundingStatus.GroundNormal = _characterUp

        if (_solveMovementCollisions) {
            // MARK: - Resolve initial overlaps
            var resolutionDirection = _cachedWorldUp
            var resolutionDistance: Float = 0
            var iterationsMade = 0
            var overlapSolved = false
            while (iterationsMade < MaxDecollisionIterations && !overlapSolved) {
                let nbOverlaps = CharacterCollisionsOverlap(position: _transientPosition, rotation: _transientRotation, overlappedColliders: _internalProbedColliders)

                if (nbOverlaps > 0) {
                    // Solve overlaps that aren't against dynamic rigidbodies or physics movers
                    for i in 0..<nbOverlaps {
                        if (GetInteractiveRigidbody(onCollider: _internalProbedColliders[i]!) == nil) {
                            // Process overlap
                            let overlappedTransform = _internalProbedColliders[i]!.entity.getComponent(vox_render.Transform.self)
                            if engine.physicsManager.computePenetration(shape0: Capsule!.shapes[0],
                                    position0: _transientPosition,
                                    rotation0: _transientRotation,
                                    shape1: _internalProbedColliders[i]!.shapes[0],
                                    position1: overlappedTransform!.position,
                                    rotation1: overlappedTransform!.rotationQuaternion,
                                    direction: &resolutionDirection,
                                    depth: &resolutionDistance) {
                                // Resolve along obstruction direction
                                var mockReport = HitStabilityReport()
                                mockReport.IsStable = IsStableOnNormal(resolutionDirection)
                                resolutionDirection = GetObstructionNormal(hitNormal: resolutionDirection, stableOnHit: mockReport.IsStable)

                                // Solve overlap
                                let resolutionMovement = resolutionDirection * (resolutionDistance + KinematicCharacterMotor.CollisionOffset)
                                _transientPosition += resolutionMovement

                                // Remember overlaps
                                if (_overlapsCount < _overlaps.count) {
                                    _overlaps[_overlapsCount] = OverlapResult(Normal: resolutionDirection, Collider: _internalProbedColliders[i])
                                    _overlapsCount += 1
                                }

                                break
                            }
                        }
                    }
                } else {
                    overlapSolved = true
                }

                iterationsMade += 1
            }
        }

        // MARK: -  Ground Probing and Snapping
        // Handle ungrounding
        if (_solveGrounding) {
            if (MustUnground()) {
                _transientPosition += _characterUp * (KinematicCharacterMotor.MinimumGroundProbingDistance * 1.5)
            } else {
                // Choose the appropriate ground probing distance
                var selectedGroundProbingDistance = KinematicCharacterMotor.MinimumGroundProbingDistance
                if (!LastGroundingStatus.SnappingPrevented && (LastGroundingStatus.IsStableOnGround || LastMovementIterationFoundAnyGround)) {
                    if (StepHandling != StepHandlingMethod.None) {
                        selectedGroundProbingDistance = max(CapsuleRadius, MaxStepHeight)
                    } else {
                        selectedGroundProbingDistance = CapsuleRadius
                    }

                    selectedGroundProbingDistance += GroundDetectionExtraDistance
                }

                ProbeGround(probingPosition: &_transientPosition, atRotation: _transientRotation,
                        probingDistance: selectedGroundProbingDistance, groundingReport: &GroundingStatus)

                if (!LastGroundingStatus.IsStableOnGround && GroundingStatus.IsStableOnGround) {
                    // Handle stable landing
                    BaseVelocity = Vector3.projectOnPlane(vector: BaseVelocity, planeNormal: CharacterUp)
                    BaseVelocity = GetDirectionTangentToSurface(direction: BaseVelocity, surfaceNormal: GroundingStatus.GroundNormal) * BaseVelocity.length()
                }
            }
        }

        LastMovementIterationFoundAnyGround = false

        if (_mustUngroundTimeCounter > 0) {
            _mustUngroundTimeCounter -= deltaTime
        }
        _mustUnground = false

        if (_solveGrounding) {
            CharacterController!.PostGroundingUpdate(deltaTime: deltaTime)
        }

        if (InteractiveRigidbodyHandling) {
            // MARK: - Interactive Rigidbody Handling
            _lastAttachedRigidbody = _attachedRigidbody
            if let AttachedRigidbodyOverride = AttachedRigidbodyOverride {
                _attachedRigidbody = AttachedRigidbodyOverride
            } else {
                // Detect interactive rigidbodies from grounding
                if GroundingStatus.IsStableOnGround,
                   let GroundCollider = GroundingStatus.GroundCollider {
                    if let interactiveRigidbody = GetInteractiveRigidbody(onCollider: GroundCollider) {
                        _attachedRigidbody = interactiveRigidbody
                    }
                } else {
                    _attachedRigidbody = nil
                }
            }

            var tmpVelocityFromCurrentAttachedRigidbody = Vector3.zero
            var tmpAngularVelocityFromCurrentAttachedRigidbody = Vector3.zero
            if let _attachedRigidbody = _attachedRigidbody {
                GetVelocityFromRigidbodyMovement(interactiveRigidbody: _attachedRigidbody, atPoint: _transientPosition,
                        deltaTime: deltaTime, linearVelocity: &tmpVelocityFromCurrentAttachedRigidbody,
                        angularVelocity: &tmpAngularVelocityFromCurrentAttachedRigidbody)
            }

            // Conserve momentum when de-stabilized from an attached rigidbody
            if (PreserveAttachedRigidbodyMomentum && _lastAttachedRigidbody != nil && _attachedRigidbody != _lastAttachedRigidbody) {
                BaseVelocity += _attachedRigidbodyVelocity
                BaseVelocity -= tmpVelocityFromCurrentAttachedRigidbody
            }

            // Process additional Velocity from attached rigidbody
            _attachedRigidbodyVelocity = _cachedZeroVector
            if let _ = _attachedRigidbody {
                _attachedRigidbodyVelocity = tmpVelocityFromCurrentAttachedRigidbody

                // Rotation from attached rigidbody
                let euler = tmpAngularVelocityFromCurrentAttachedRigidbody * MathUtil.radToDegreeFactor * deltaTime
                let newForward = Vector3.projectOnPlane(vector: Vector3.transformByQuat(v: _characterForward, quaternion:
                Quaternion.rotationEuler(x: euler.x, y: euler.y, z: euler.z)),
                        planeNormal: _characterUp).normalized()
                TransientRotation = Matrix.lookAt(eye: Vector3(), target: newForward, up: _characterUp).getRotation()
            }

            // Cancel out horizontal velocity upon landing on an attached rigidbody
            if (GroundingStatus.GroundCollider != nil &&
                    GroundingStatus.GroundCollider == _attachedRigidbody &&
                    _attachedRigidbody != nil &&
                    _lastAttachedRigidbody == nil) {
                BaseVelocity -= Vector3.projectOnPlane(vector: _attachedRigidbodyVelocity, planeNormal: _characterUp)
            }

            // Movement from Attached Rigidbody
            if (_attachedRigidbodyVelocity.lengthSquared() > 0) {
                _isMovingFromAttachedRigidbody = true

                if (_solveMovementCollisions) {
                    // Perform the move from rigidbody velocity
                    _ = InternalCharacterMove(transientVelocity: &_attachedRigidbodyVelocity, deltaTime: deltaTime)
                } else {
                    _transientPosition += _attachedRigidbodyVelocity * deltaTime
                }

                _isMovingFromAttachedRigidbody = false
            }
        }
    }

    /// Update phase 2 is meant to be called after physics movers have simulated their goal positions/rotations.
    /// At the end of this, the TransientPosition/Rotation values will be up-to-date with where the motor should be at the end of its move.
    /// It is responsible for:
    /// - Solving Rotation
    /// - Handle MoveRotation calls
    /// - Solving potential attached rigidbody overlaps
    /// - Solving Velocity
    /// - Applying planar constraint
    public func UpdatePhase2(deltaTime: Float) {
        // Handle rotation
        CharacterController!.UpdateRotation(currentRotation: &_transientRotation, deltaTime: deltaTime)
        TransientRotation = _transientRotation

        // Handle move rotation
        if (_moveRotationDirty) {
            TransientRotation = _moveRotationTarget
            _moveRotationDirty = false
        }

        if (_solveMovementCollisions && InteractiveRigidbodyHandling) {
            if (InteractiveRigidbodyHandling) {
                // MARK: - Solve potential attached rigidbody overlap
                if let _attachedRigidbody = _attachedRigidbody {
                    let upwardsOffset = (Capsule!.shapes[0] as! CapsuleColliderShape).radius

                    var closestHit = HitResult()
                    if (CharacterGroundSweep(
                            position: _transientPosition + (_characterUp * upwardsOffset),
                            rotation: _transientRotation,
                            direction: -_characterUp,
                            distance: upwardsOffset,
                            closestHit: &closestHit)) {
                        if (closestHit.collider == _attachedRigidbody && IsStableOnNormal(closestHit.normal)) {
                            let distanceMovedUp = (upwardsOffset - closestHit.distance)
                            _transientPosition = _transientPosition + (_characterUp * distanceMovedUp) + (_characterUp * KinematicCharacterMotor.CollisionOffset)
                        }
                    }
                }
            }

            if (InteractiveRigidbodyHandling) {
                // MARK: -Resolve overlaps that could've been caused by rotation or physics movers simulation pushing the character
                var resolutionDirection = _cachedWorldUp
                var resolutionDistance: Float = 0
                var iterationsMade = 0
                var overlapSolved = false
                while (iterationsMade < MaxDecollisionIterations && !overlapSolved) {
                    let nbOverlaps = CharacterCollisionsOverlap(position: _transientPosition, rotation: _transientRotation,
                            overlappedColliders: _internalProbedColliders)
                    if (nbOverlaps > 0) {
                        for i in 0..<nbOverlaps {
                            // Process overlap
                            let overlappedTransform = _internalProbedColliders[i]!.entity.getComponent(vox_render.Transform.self)
                            if (engine.physicsManager.computePenetration(shape0: Capsule!.shapes[0] as! CapsuleColliderShape,
                                    position0: _transientPosition,
                                    rotation0: _transientRotation,
                                    shape1: _internalProbedColliders[i]!.shapes[0],
                                    position1: overlappedTransform!.position,
                                    rotation1: overlappedTransform!.rotationQuaternion,
                                    direction: &resolutionDirection,
                                    depth: &resolutionDistance)) {
                                // Resolve along obstruction direction
                                var mockReport = HitStabilityReport()
                                mockReport.IsStable = IsStableOnNormal(resolutionDirection)
                                resolutionDirection = GetObstructionNormal(hitNormal: resolutionDirection, stableOnHit: mockReport.IsStable)

                                // Solve overlap
                                let resolutionMovement = resolutionDirection * (resolutionDistance + KinematicCharacterMotor.CollisionOffset)
                                _transientPosition += resolutionMovement

                                // If interactiveRigidbody, register as rigidbody hit for velocity
                                if (InteractiveRigidbodyHandling) {
                                    let probedRigidbody = GetInteractiveRigidbody(onCollider: _internalProbedColliders[i]!)
                                    if (probedRigidbody != nil) {
                                        var tmpReport = HitStabilityReport()
                                        tmpReport.IsStable = IsStableOnNormal(resolutionDirection)
                                        if (tmpReport.IsStable) {
                                            LastMovementIterationFoundAnyGround = tmpReport.IsStable
                                        }
                                        if (probedRigidbody != _attachedRigidbody) {
                                            let estimatedCollisionPoint = _transientPosition
                                            StoreRigidbodyHit(
                                                    hitRigidbody: probedRigidbody!,
                                                    hitVelocity: Velocity,
                                                    hitPoint: estimatedCollisionPoint,
                                                    obstructionNormal: resolutionDirection,
                                                    hitStabilityReport: tmpReport)
                                        }
                                    }
                                }

                                // Remember overlaps
                                if (_overlapsCount < _overlaps.count) {
                                    _overlaps[_overlapsCount] = OverlapResult(Normal: resolutionDirection, Collider: _internalProbedColliders[i])
                                    _overlapsCount += 1
                                }

                                break
                            }
                        }
                    } else {
                        overlapSolved = true
                    }

                    iterationsMade += 1
                }
            }
        }

        // Handle velocity
        CharacterController!.UpdateVelocity(currentVelocity: &BaseVelocity, deltaTime: deltaTime)

        //this.CharacterController.UpdateVelocity(ref BaseVelocity, deltaTime)
        if (BaseVelocity.length() < KinematicCharacterMotor.MinVelocityMagnitude) {
            BaseVelocity = Vector3.zero
        }

        // MARK: - Calculate Character movement from base velocity
        // Perform the move from base velocity
        if (BaseVelocity.lengthSquared() > 0) {
            if (_solveMovementCollisions) {
                _ = InternalCharacterMove(transientVelocity: &BaseVelocity, deltaTime: deltaTime)
            } else {
                _transientPosition += BaseVelocity * deltaTime
            }
        }

        // Process rigidbody hits/overlaps to affect velocity
        if (InteractiveRigidbodyHandling) {
            ProcessVelocityForRigidbodyHits(processedVelocity: &BaseVelocity, deltaTime: deltaTime)
        }

        // Handle planar constraint
        if (HasPlanarConstraint) {
            _transientPosition = _initialSimulationPosition + Vector3.projectOnPlane(vector: _transientPosition - _initialSimulationPosition,
                    planeNormal: PlanarConstraintAxis.normalized())
        }

        // Discrete collision detection
        if (DiscreteCollisionEvents) {
            let nbOverlaps = CharacterCollisionsOverlap(position: _transientPosition, rotation: _transientRotation,
                    overlappedColliders: _internalProbedColliders,
                    inflate: KinematicCharacterMotor.CollisionOffset * 2)
            for i in 0..<nbOverlaps {
                CharacterController!.OnDiscreteCollisionDetected(hitCollider: _internalProbedColliders[i]!)
            }
        }

        CharacterController!.AfterCharacterUpdate(deltaTime: deltaTime)
    }

    /// Determines if motor can be considered stable on given slope normal
    private func IsStableOnNormal(_ normal: Vector3) -> Bool {
        return Vector3.angle(from: _characterUp, to: normal) <= MaxStableSlopeAngle
    }

    /// Determines if motor can be considered stable on given slope normal
    private func IsStableWithSpecialCases(stabilityReport: inout HitStabilityReport, velocity: Vector3) -> Bool {
        if (LedgeAndDenivelationHandling) {
            if (stabilityReport.LedgeDetected) {
                if (stabilityReport.IsMovingTowardsEmptySideOfLedge) {
                    // Max snap vel
                    let velocityOnLedgeNormal = Vector3.project(vector: velocity, onNormal: stabilityReport.LedgeFacingDirection)
                    if (velocityOnLedgeNormal.length() >= MaxVelocityForLedgeSnap) {
                        return false
                    }
                }

                // Distance from ledge
                if (stabilityReport.IsOnEmptySideOfLedge && stabilityReport.DistanceFromLedge > MaxStableDistanceFromLedge) {
                    return false
                }
            }

            // "Launching" off of slopes of a certain denivelation angle
            if (LastGroundingStatus.FoundAnyGround && stabilityReport.InnerNormal.lengthSquared() != 0 && stabilityReport.OuterNormal.lengthSquared() != 0) {
                var denivelationAngle = Vector3.angle(from: stabilityReport.InnerNormal, to: stabilityReport.OuterNormal)
                if (denivelationAngle > MaxStableDenivelationAngle) {
                    return false
                } else {
                    denivelationAngle = Vector3.angle(from: LastGroundingStatus.InnerGroundNormal, to: stabilityReport.OuterNormal)
                    if (denivelationAngle > MaxStableDenivelationAngle) {
                        return false
                    }
                }
            }
        }

        return true
    }

    /// Probes for valid ground and midifies the input transientPosition if ground snapping occurs
    public func ProbeGround(probingPosition: inout Vector3, atRotation: Quaternion, probingDistance: Float, groundingReport: inout CharacterGroundingReport) {
        var probingDistance = probingDistance
        if (probingDistance < KinematicCharacterMotor.MinimumGroundProbingDistance) {
            probingDistance = KinematicCharacterMotor.MinimumGroundProbingDistance
        }

        var groundSweepsMade = 0
        var groundSweepHit = HitResult()
        var groundSweepingIsOver = false
        var groundSweepPosition = probingPosition
        var groundSweepDirection = Vector3.transformByQuat(v: -_cachedWorldUp, quaternion: atRotation)
        var groundProbeDistanceRemaining = probingDistance
        while (groundProbeDistanceRemaining > 0 && (groundSweepsMade <= KinematicCharacterMotor.MaxGroundingSweepIterations) && !groundSweepingIsOver) {
            // Sweep for ground detection
            if (CharacterGroundSweep(
                    position: groundSweepPosition,
                    rotation: atRotation,
                    direction: groundSweepDirection,
                    distance: groundProbeDistanceRemaining,
                    closestHit: &groundSweepHit)) {
                let targetPosition = groundSweepPosition + (groundSweepDirection * groundSweepHit.distance)
                var groundHitStabilityReport = HitStabilityReport()
                EvaluateHitStability(hitCollider: groundSweepHit.collider!,
                        hitNormal: groundSweepHit.normal,
                        hitPoint: groundSweepHit.point,
                        atCharacterPosition: targetPosition,
                        atCharacterRotation: _transientRotation,
                        withCharacterVelocity: BaseVelocity,
                        stabilityReport: &groundHitStabilityReport)

                groundingReport.FoundAnyGround = true
                groundingReport.GroundNormal = groundSweepHit.normal
                groundingReport.InnerGroundNormal = groundHitStabilityReport.InnerNormal
                groundingReport.OuterGroundNormal = groundHitStabilityReport.OuterNormal
                groundingReport.GroundCollider = groundSweepHit.collider
                groundingReport.GroundPoint = groundSweepHit.point
                groundingReport.SnappingPrevented = false

                // Found stable ground
                if (groundHitStabilityReport.IsStable) {
                    // Find all scenarios where ground snapping should be canceled
                    groundingReport.SnappingPrevented = !IsStableWithSpecialCases(stabilityReport: &groundHitStabilityReport, velocity: BaseVelocity)

                    groundingReport.IsStableOnGround = true

                    // Ground snapping
                    if (!groundingReport.SnappingPrevented) {
                        probingPosition = groundSweepPosition + (groundSweepDirection * (groundSweepHit.distance - KinematicCharacterMotor.CollisionOffset))
                    }

                    CharacterController!.OnGroundHit(hitCollider: groundSweepHit.collider!, hitNormal: groundSweepHit.normal,
                            hitPoint: groundSweepHit.point, hitStabilityReport: &groundHitStabilityReport)
                    groundSweepingIsOver = true
                } else {
                    // Calculate movement from this iteration and advance position
                    let sweepMovement = (groundSweepDirection * groundSweepHit.distance)
                            + (Vector3.transformByQuat(v: _cachedWorldUp, quaternion: atRotation) * max(KinematicCharacterMotor.CollisionOffset, groundSweepHit.distance))
                    groundSweepPosition = groundSweepPosition + sweepMovement

                    // Set remaining distance
                    groundProbeDistanceRemaining = min(KinematicCharacterMotor.GroundProbeReboundDistance,
                            max(groundProbeDistanceRemaining - sweepMovement.length(), 0))

                    // Reorient direction
                    groundSweepDirection = Vector3.projectOnPlane(vector: groundSweepDirection, planeNormal: groundSweepHit.normal).normalized()
                }
            } else {
                groundSweepingIsOver = true
            }

            groundSweepsMade += 1
        }
    }

    /// Forces the character to unground itself on its next grounding update
    public func ForceUnground(time: Float = 0.1) {
        _mustUnground = true
        _mustUngroundTimeCounter = time
    }

    public func MustUnground() -> Bool {
        return _mustUnground || _mustUngroundTimeCounter > 0
    }

    /// Returns the direction adjusted to be tangent to a specified surface normal relatively to the character's up direction.
    /// Useful for reorienting a direction on a slope without any lateral deviation in trajectory
    public func GetDirectionTangentToSurface(direction: Vector3, surfaceNormal: Vector3) -> Vector3 {
        let directionRight = Vector3.cross(left: direction, right: _characterUp)
        return Vector3.cross(left: surfaceNormal, right: directionRight).normalized()
    }

    /// Moves the character's position by given movement while taking into account all physics simulation, step-handling and
    /// velocity projection rules that affect the character motor
    /// - Returns: Returns false if movement could not be solved until the end
    private func InternalCharacterMove(transientVelocity: inout Vector3, deltaTime: Float) -> Bool {
        if (deltaTime <= 0) {
            return false
        }

        // Planar constraint
        if (HasPlanarConstraint) {
            transientVelocity = Vector3.projectOnPlane(vector: transientVelocity, planeNormal: PlanarConstraintAxis.normalized())
        }

        var wasCompleted = true
        var remainingMovementDirection = transientVelocity.normalized()
        var remainingMovementMagnitude = transientVelocity.length() * deltaTime
        let originalVelocityDirection = remainingMovementDirection
        var sweepsMade = 0
        var hitSomethingThisSweepIteration = true
        var tmpMovedPosition = _transientPosition
        var previousHitIsStable = false
        var previousVelocity = _cachedZeroVector
        var previousObstructionNormal = _cachedZeroVector
        var sweepState = MovementSweepState.Initial

        // Project movement against current overlaps before doing the sweeps
        for i in 0..<_overlapsCount {
            let overlapNormal = _overlaps[i].Normal
            if (Vector3.dot(left: remainingMovementDirection, right: overlapNormal) < 0) {
                let stableOnHit = IsStableOnNormal(overlapNormal) && !MustUnground()
                let velocityBeforeProjection = transientVelocity
                let obstructionNormal = GetObstructionNormal(hitNormal: overlapNormal, stableOnHit: stableOnHit)

                InternalHandleVelocityProjection(
                        stableOnHit: stableOnHit,
                        hitNormal: overlapNormal,
                        obstructionNormal: obstructionNormal,
                        originalDirection: originalVelocityDirection,
                        sweepState: &sweepState,
                        previousHitIsStable: previousHitIsStable,
                        previousVelocity: previousVelocity,
                        previousObstructionNormal: previousObstructionNormal,
                        transientVelocity: &transientVelocity,
                        remainingMovementMagnitude: &remainingMovementMagnitude,
                        remainingMovementDirection: &remainingMovementDirection)

                previousHitIsStable = stableOnHit
                previousVelocity = velocityBeforeProjection
                previousObstructionNormal = obstructionNormal
            }
        }

        // Sweep the desired movement to detect collisions
        while (remainingMovementMagnitude > 0 &&
                (sweepsMade <= MaxMovementIterations) &&
                hitSomethingThisSweepIteration) {
            var foundClosestHit = false
            var closestSweepHitPoint = Vector3()
            var closestSweepHitNormal = Vector3()
            var closestSweepHitDistance: Float = 0
            var closestSweepHitCollider: Collider? = nil

            if (CheckMovementInitialOverlaps) {
                let numOverlaps = CharacterCollisionsOverlap(
                        position: tmpMovedPosition,
                        rotation: _transientRotation,
                        overlappedColliders: _internalProbedColliders,
                        inflate: 0,
                        acceptOnlyStableGroundLayer: false)
                if (numOverlaps > 0) {
                    closestSweepHitDistance = 0

                    var mostObstructingOverlapNormalDotProduct: Float = 2

                    for i in 0..<numOverlaps {
                        let tmpCollider = _internalProbedColliders[i]

                        var resolutionDirection = Vector3()
                        var resolutionDistance: Float = 0
                        if (engine.physicsManager.computePenetration(shape0: Capsule!.shapes[0],
                                position0: tmpMovedPosition,
                                rotation0: _transientRotation,
                                shape1: tmpCollider!.shapes[0],
                                position1: tmpCollider!.entity.transform.position,
                                rotation1: tmpCollider!.entity.transform.rotationQuaternion,
                                direction: &resolutionDirection, depth: &resolutionDistance)) {
                            let dotProduct = Vector3.dot(left: remainingMovementDirection, right: resolutionDirection)
                            if (dotProduct < 0 && dotProduct < mostObstructingOverlapNormalDotProduct) {
                                mostObstructingOverlapNormalDotProduct = dotProduct

                                closestSweepHitNormal = resolutionDirection
                                closestSweepHitCollider = tmpCollider
                                closestSweepHitPoint = tmpMovedPosition + Vector3.transformByQuat(v: CharacterTransformToCapsuleCenter,
                                        quaternion: _transientRotation)
                                        + (resolutionDirection * resolutionDistance)

                                foundClosestHit = true
                            }
                        }
                    }
                }
            }

            var closestSweepHit = HitResult()
            if (!foundClosestHit && CharacterCollisionsSweep(
                    position: tmpMovedPosition, // position
                    rotation: _transientRotation, // rotation
                    direction: remainingMovementDirection, // direction
                    distance: remainingMovementMagnitude + KinematicCharacterMotor.CollisionOffset, // distance
                    closestHit: &closestSweepHit, // closest hit
                    hits: _internalCharacterHits) // all hits
                    > 0) {
                closestSweepHitNormal = closestSweepHit.normal
                closestSweepHitDistance = closestSweepHit.distance
                closestSweepHitCollider = closestSweepHit.collider
                closestSweepHitPoint = closestSweepHit.point

                foundClosestHit = true
            }

            if (foundClosestHit) {
                // Calculate movement from this iteration
                let sweepMovement = (remainingMovementDirection * (max(0, closestSweepHitDistance - KinematicCharacterMotor.CollisionOffset)))
                tmpMovedPosition += sweepMovement
                remainingMovementMagnitude -= sweepMovement.length()

                // Evaluate if hit is stable
                var moveHitStabilityReport = HitStabilityReport()
                EvaluateHitStability(hitCollider: closestSweepHitCollider!, hitNormal: closestSweepHitNormal, hitPoint: closestSweepHitPoint,
                        atCharacterPosition: tmpMovedPosition, atCharacterRotation: _transientRotation,
                        withCharacterVelocity: transientVelocity, stabilityReport: &moveHitStabilityReport)

                // Handle stepping up steps points higher than bottom capsule radius
                var foundValidStepHit = false
                if (_solveGrounding && StepHandling != StepHandlingMethod.None && moveHitStabilityReport.ValidStepDetected) {
                    let obstructionCorrelation = abs(Vector3.dot(left: closestSweepHitNormal, right: _characterUp))
                    if (obstructionCorrelation <= KinematicCharacterMotor.CorrelationForVerticalObstruction) {
                        let stepForwardDirection = Vector3.projectOnPlane(vector: -closestSweepHitNormal, planeNormal: _characterUp).normalized()
                        let stepCastStartPoint = (tmpMovedPosition + (stepForwardDirection * KinematicCharacterMotor.SteppingForwardDistance)) +
                                (_characterUp * MaxStepHeight)

                        var closestStepHit = HitResult()
                        // Cast downward from the top of the stepping height
                        let nbStepHits = CharacterCollisionsSweep(
                                position: stepCastStartPoint, // position
                                rotation: _transientRotation, // rotation
                                direction: -_characterUp, // direction
                                distance: MaxStepHeight, // distance
                                closestHit: &closestStepHit, // closest hit
                                hits: _internalCharacterHits,
                                inflate: 0,
                                acceptOnlyStableGroundLayer: true) // all hits

                        // Check for hit corresponding to stepped collider
                        for i in 0..<nbStepHits {
                            if (_internalCharacterHits[i].collider == moveHitStabilityReport.SteppedCollider) {
                                let endStepPosition = stepCastStartPoint + (-_characterUp * (_internalCharacterHits[i].distance - KinematicCharacterMotor.CollisionOffset))
                                tmpMovedPosition = endStepPosition
                                foundValidStepHit = true

                                // Project velocity on ground normal at step
                                transientVelocity = Vector3.projectOnPlane(vector: transientVelocity, planeNormal: CharacterUp)
                                remainingMovementDirection = transientVelocity.normalized()

                                break
                            }
                        }
                    }
                }

                // Handle movement solving
                if (!foundValidStepHit) {
                    let obstructionNormal = GetObstructionNormal(hitNormal: closestSweepHitNormal, stableOnHit: moveHitStabilityReport.IsStable)

                    // Movement hit callback
                    CharacterController!.OnMovementHit(hitCollider: closestSweepHitCollider!, hitNormal: closestSweepHitNormal,
                            hitPoint: closestSweepHitPoint, hitStabilityReport: &moveHitStabilityReport)

                    // Handle remembering rigidbody hits
                    if InteractiveRigidbodyHandling,
                       let attachedRigidbody = closestSweepHitCollider as? DynamicCollider {
                        StoreRigidbodyHit(
                                hitRigidbody: attachedRigidbody,
                                hitVelocity: transientVelocity,
                                hitPoint: closestSweepHitPoint,
                                obstructionNormal: obstructionNormal,
                                hitStabilityReport: moveHitStabilityReport)
                    }

                    let stableOnHit = moveHitStabilityReport.IsStable && !MustUnground()
                    let velocityBeforeProj = transientVelocity

                    // Project velocity for next iteration
                    InternalHandleVelocityProjection(
                            stableOnHit: stableOnHit,
                            hitNormal: closestSweepHitNormal,
                            obstructionNormal: obstructionNormal,
                            originalDirection: originalVelocityDirection,
                            sweepState: &sweepState,
                            previousHitIsStable: previousHitIsStable,
                            previousVelocity: previousVelocity,
                            previousObstructionNormal: previousObstructionNormal,
                            transientVelocity: &transientVelocity,
                            remainingMovementMagnitude: &remainingMovementMagnitude,
                            remainingMovementDirection: &remainingMovementDirection)

                    previousHitIsStable = stableOnHit
                    previousVelocity = velocityBeforeProj
                    previousObstructionNormal = obstructionNormal
                }
            }
            // If we hit nothing...
            else {
                hitSomethingThisSweepIteration = false
            }

            // Safety for exceeding max sweeps allowed
            sweepsMade += 1
            if (sweepsMade > MaxMovementIterations) {
                if (KillRemainingMovementWhenExceedMaxMovementIterations) {
                    remainingMovementMagnitude = 0
                }

                if (KillVelocityWhenExceedMaxMovementIterations) {
                    transientVelocity = Vector3.zero
                }
                wasCompleted = false
            }
        }

        // Move position for the remainder of the movement
        tmpMovedPosition += (remainingMovementDirection * remainingMovementMagnitude)
        _transientPosition = tmpMovedPosition

        return wasCompleted
    }

    /// Gets the effective normal for movement obstruction depending on current grounding status
    private func GetObstructionNormal(hitNormal: Vector3, stableOnHit: Bool) -> Vector3 {
        // Find hit/obstruction/offset normal
        var obstructionNormal = hitNormal
        if (GroundingStatus.IsStableOnGround && !MustUnground() && !stableOnHit) {
            let obstructionLeftAlongGround = Vector3.cross(left: GroundingStatus.GroundNormal, right: obstructionNormal).normalized()
            obstructionNormal = Vector3.cross(left: obstructionLeftAlongGround, right: _characterUp).normalized()
        }

        // Catch cases where cross product between parallel normals returned 0
        if (obstructionNormal.lengthSquared() == 0) {
            obstructionNormal = hitNormal
        }

        return obstructionNormal
    }

    /// Remembers a rigidbody hit for processing later
    private func StoreRigidbodyHit(hitRigidbody: DynamicCollider, hitVelocity: Vector3,
                                   hitPoint: Vector3, obstructionNormal: Vector3, hitStabilityReport: HitStabilityReport) {
        if (_rigidbodyProjectionHitCount < _internalRigidbodyProjectionHits.count) {
            if hitRigidbody.entity.getComponent(KinematicCharacterMotor.self) != nil {
                var rph = RigidbodyProjectionHit()
                rph.Rigidbody = hitRigidbody
                rph.HitPoint = hitPoint
                rph.EffectiveHitNormal = obstructionNormal
                rph.HitVelocity = hitVelocity
                rph.StableOnHit = hitStabilityReport.IsStable

                _internalRigidbodyProjectionHits[_rigidbodyProjectionHitCount] = rph
                _rigidbodyProjectionHitCount += 1
            }
        }
    }

    public func SetTransientPosition(_ newPos: Vector3) {
        _transientPosition = newPos
    }

    /// Processes movement projection upon detecting a hit
    private func InternalHandleVelocityProjection(stableOnHit: Bool, hitNormal: Vector3, obstructionNormal: Vector3, originalDirection: Vector3,
                                                  sweepState: inout MovementSweepState, previousHitIsStable: Bool, previousVelocity: Vector3, previousObstructionNormal: Vector3,
                                                  transientVelocity: inout Vector3, remainingMovementMagnitude: inout Float, remainingMovementDirection: inout Vector3) {
        if (transientVelocity.lengthSquared() <= 0) {
            return
        }

        let velocityBeforeProjection = transientVelocity

        if (stableOnHit) {
            LastMovementIterationFoundAnyGround = true
            HandleVelocityProjection(velocity: &transientVelocity, obstructionNormal: obstructionNormal, stableOnHit: stableOnHit)
        } else {
            // Handle projection
            if (sweepState == MovementSweepState.Initial) {
                HandleVelocityProjection(velocity: &transientVelocity, obstructionNormal: obstructionNormal, stableOnHit: stableOnHit)
                sweepState = MovementSweepState.AfterFirstHit
            }
            // Blocking crease handling
            else if (sweepState == MovementSweepState.AfterFirstHit) {
                var foundCrease = false
                var creaseDirection = Vector3()
                EvaluateCrease(
                        currentCharacterVelocity: transientVelocity,
                        previousCharacterVelocity: previousVelocity,
                        currentHitNormal: obstructionNormal,
                        previousHitNormal: previousObstructionNormal,
                        currentHitIsStable: stableOnHit,
                        previousHitIsStable: previousHitIsStable,
                        characterIsStable: GroundingStatus.IsStableOnGround && !MustUnground(),
                        isValidCrease: &foundCrease,
                        creaseDirection: &creaseDirection)

                if (foundCrease) {
                    if (GroundingStatus.IsStableOnGround && !MustUnground()) {
                        transientVelocity = Vector3.zero
                        sweepState = MovementSweepState.FoundBlockingCorner
                    } else {
                        transientVelocity = Vector3.project(vector: transientVelocity, onNormal: creaseDirection)
                        sweepState = MovementSweepState.FoundBlockingCrease
                    }
                } else {
                    HandleVelocityProjection(velocity: &transientVelocity, obstructionNormal: obstructionNormal, stableOnHit: stableOnHit)
                }
            }
            // Blocking corner handling
            else if (sweepState == MovementSweepState.FoundBlockingCrease) {
                transientVelocity = Vector3.zero
                sweepState = MovementSweepState.FoundBlockingCorner
            }
        }

        if (HasPlanarConstraint) {
            transientVelocity = Vector3.projectOnPlane(vector: transientVelocity, planeNormal: PlanarConstraintAxis.normalized())
        }

        let newVelocityFactor = transientVelocity.length() / velocityBeforeProjection.length()
        remainingMovementMagnitude *= newVelocityFactor
        remainingMovementDirection = transientVelocity.normalized()
    }

    private func EvaluateCrease(currentCharacterVelocity: Vector3,
                                previousCharacterVelocity: Vector3,
                                currentHitNormal: Vector3,
                                previousHitNormal: Vector3,
                                currentHitIsStable: Bool,
                                previousHitIsStable: Bool,
                                characterIsStable: Bool,
                                isValidCrease: inout Bool,
                                creaseDirection: inout Vector3) {
        isValidCrease = false
        creaseDirection = Vector3()

        if (!characterIsStable || !currentHitIsStable || !previousHitIsStable) {
            var tmpBlockingCreaseDirection = Vector3.cross(left: currentHitNormal, right: previousHitNormal).normalized()
            let dotPlanes = Vector3.dot(left: currentHitNormal, right: previousHitNormal)
            var isVelocityConstrainedByCrease = false

            // Avoid calculations if the two planes are the same
            if (dotPlanes < 0.999) {
                // TODO: can this whole part be made simpler? (with 2d projections, etc)
                let normalAOnCreasePlane = Vector3.projectOnPlane(vector: currentHitNormal, planeNormal: tmpBlockingCreaseDirection).normalized()
                let normalBOnCreasePlane = Vector3.projectOnPlane(vector: previousHitNormal, planeNormal: tmpBlockingCreaseDirection).normalized()
                let dotPlanesOnCreasePlane = Vector3.dot(left: normalAOnCreasePlane, right: normalBOnCreasePlane)

                let enteringVelocityDirectionOnCreasePlane = Vector3.projectOnPlane(vector: previousCharacterVelocity, planeNormal: tmpBlockingCreaseDirection).normalized()

                if (dotPlanesOnCreasePlane <= (Vector3.dot(left: -enteringVelocityDirectionOnCreasePlane, right: normalAOnCreasePlane) + 0.001) &&
                        dotPlanesOnCreasePlane <= (Vector3.dot(left: -enteringVelocityDirectionOnCreasePlane, right: normalBOnCreasePlane) + 0.001)) {
                    isVelocityConstrainedByCrease = true
                }
            }

            if (isVelocityConstrainedByCrease) {
                // Flip crease direction to make it representative of the real direction our velocity would be projected to
                if (Vector3.dot(left: tmpBlockingCreaseDirection, right: currentCharacterVelocity) < 0) {
                    tmpBlockingCreaseDirection = -tmpBlockingCreaseDirection
                }

                isValidCrease = true
                creaseDirection = tmpBlockingCreaseDirection
            }
        }
    }

    /// Allows you to override the way velocity is projected on an obstruction
    public func HandleVelocityProjection(velocity: inout Vector3, obstructionNormal: Vector3, stableOnHit: Bool) {
        if (GroundingStatus.IsStableOnGround && !MustUnground()) {
            // On stable slopes, simply reorient the movement without any loss
            if (stableOnHit) {
                velocity = GetDirectionTangentToSurface(direction: velocity, surfaceNormal: obstructionNormal) * velocity.length()
            }
            // On blocking hits, project the movement on the obstruction while following the grounding plane
            else {
                let obstructionRightAlongGround = Vector3.cross(left: obstructionNormal, right: GroundingStatus.GroundNormal).normalized()
                let obstructionUpAlongGround = Vector3.cross(left: obstructionRightAlongGround, right: obstructionNormal).normalized()
                velocity = GetDirectionTangentToSurface(direction: velocity, surfaceNormal: obstructionUpAlongGround) * velocity.length()
                velocity = Vector3.projectOnPlane(vector: velocity, planeNormal: obstructionNormal)
            }
        } else {
            if (stableOnHit) {
                // Handle stable landing
                velocity = Vector3.projectOnPlane(vector: velocity, planeNormal: CharacterUp)
                velocity = GetDirectionTangentToSurface(direction: velocity, surfaceNormal: obstructionNormal) * velocity.length()
            }
            // Handle generic obstruction
            else {
                velocity = Vector3.projectOnPlane(vector: velocity, planeNormal: obstructionNormal)
            }
        }
    }

    /// Allows you to override the way hit rigidbodies are pushed / interacted with.
    /// ProcessedVelocity is what must be modified if this interaction affects the character's velocity.
    public func HandleSimulatedRigidbodyInteraction(processedVelocity: inout Vector3, hit: RigidbodyProjectionHit, deltaTime: Float) {
    }

    /// Takes into account rigidbody hits for adding to the velocity
    private func ProcessVelocityForRigidbodyHits(processedVelocity: inout Vector3, deltaTime: Float) {
        for i in 0..<_rigidbodyProjectionHitCount {
            let bodyHit = _internalRigidbodyProjectionHits[i]

            if let Rigidbody = bodyHit.Rigidbody,
               !_rigidbodiesPushedThisMove.contains(Rigidbody) {
                if (_internalRigidbodyProjectionHits[i].Rigidbody != _attachedRigidbody) {
                    // Remember we hit this rigidbody
                    _rigidbodiesPushedThisMove.append(bodyHit.Rigidbody)

                    let characterMass = SimulatedCharacterMass
                    let characterVelocity = bodyHit.HitVelocity

                    let hitCharacterMotor = Rigidbody.entity.getComponent(KinematicCharacterMotor.self)
                    let hitBodyIsDynamic = !Rigidbody.isKinematic
                    var hitBodyMassAtPoint = Rigidbody.mass // todo
                    var hitBodyVelocity = Rigidbody.linearVelocity
                    if let hitCharacterMotor = hitCharacterMotor {
                        hitBodyMassAtPoint = hitCharacterMotor.SimulatedCharacterMass // todo
                        hitBodyVelocity = hitCharacterMotor.BaseVelocity
                    } else if (!hitBodyIsDynamic) {
                        if let physicsMover = Rigidbody.entity.getComponent(PhysicsMover.self) {
                            hitBodyVelocity = physicsMover.Velocity
                        }
                    }

                    // Calculate the ratio of the total mass that the character mass represents
                    var characterToBodyMassRatio: Float = 1
                    if (characterMass + hitBodyMassAtPoint > 0) {
                        characterToBodyMassRatio = characterMass / (characterMass + hitBodyMassAtPoint)
                    } else {
                        characterToBodyMassRatio = 0.5
                    }

                    // Hitting a non-dynamic body
                    if (!hitBodyIsDynamic) {
                        characterToBodyMassRatio = 0
                    }
                    // Emulate kinematic body interaction
                    else if (rigidbodyInteractionType == RigidbodyInteractionType.Kinematic && hitCharacterMotor == nil) {
                        characterToBodyMassRatio = 1
                    }

                    var velocityChangeOnCharacter = Vector3()
                    var velocityChangeOnBody = Vector3()
                    ComputeCollisionResolutionForHitBody(
                            hitNormal: bodyHit.EffectiveHitNormal,
                            characterVelocity: characterVelocity,
                            bodyVelocity: hitBodyVelocity,
                            characterToBodyMassRatio: characterToBodyMassRatio,
                            velocityChangeOnCharacter: &velocityChangeOnCharacter,
                            velocityChangeOnBody: &velocityChangeOnBody)

                    processedVelocity += velocityChangeOnCharacter

                    if let hitCharacterMotor = hitCharacterMotor {
                        hitCharacterMotor.BaseVelocity += velocityChangeOnCharacter
                    } else if (hitBodyIsDynamic) {
                        Rigidbody.applyForceAtPosition(velocityChangeOnBody, bodyHit.HitPoint, mode: eVELOCITY_CHANGE)
                    }

                    if (rigidbodyInteractionType == RigidbodyInteractionType.SimulatedDynamic) {
                        HandleSimulatedRigidbodyInteraction(processedVelocity: &processedVelocity, hit: bodyHit, deltaTime: deltaTime)
                    }
                }
            }
        }
    }

    public func ComputeCollisionResolutionForHitBody(
            hitNormal: Vector3,
            characterVelocity: Vector3,
            bodyVelocity: Vector3,
            characterToBodyMassRatio: Float,
            velocityChangeOnCharacter: inout Vector3,
            velocityChangeOnBody: inout Vector3) {
        velocityChangeOnCharacter = Vector3()
        velocityChangeOnBody = Vector3()

        let bodyToCharacterMassRatio = 1 - characterToBodyMassRatio
        let characterVelocityMagnitudeOnHitNormal = Vector3.dot(left: characterVelocity, right: hitNormal)
        let bodyVelocityMagnitudeOnHitNormal = Vector3.dot(left: bodyVelocity, right: hitNormal)

        // if character velocity was going against the obstruction, restore the portion of the velocity that got projected during the movement phase
        if (characterVelocityMagnitudeOnHitNormal < 0) {
            let restoredCharacterVelocity = hitNormal * characterVelocityMagnitudeOnHitNormal
            velocityChangeOnCharacter += restoredCharacterVelocity
        }

        // solve impulse velocities on both bodies, but only if the body velocity would be giving resistance to the character in any way
        if (bodyVelocityMagnitudeOnHitNormal > characterVelocityMagnitudeOnHitNormal) {
            let relativeImpactVelocity = hitNormal * (bodyVelocityMagnitudeOnHitNormal - characterVelocityMagnitudeOnHitNormal)
            velocityChangeOnCharacter += relativeImpactVelocity * bodyToCharacterMassRatio
            velocityChangeOnBody += -relativeImpactVelocity * characterToBodyMassRatio
        }
    }

    /// Determines if the input collider is valid for collision processing
    /// - Parameter coll: coll
    /// - Returns: Returns true if the collider is valid
    private func CheckIfColliderValidForCollisions(_ coll: Collider) -> Bool {
        // Ignore self
        if (coll == Capsule) {
            return false
        }

        if (!InternalIsColliderValidForCollisions(coll)) {
            return false
        }

        return true
    }

    /// Determines if the input collider is valid for collision processing
    private func InternalIsColliderValidForCollisions(_ coll: Collider) -> Bool {
        if let colliderAttachedRigidbody = coll as? DynamicCollider {
            let isRigidbodyKinematic = colliderAttachedRigidbody.isKinematic

            // If movement is made from AttachedRigidbody, ignore the AttachedRigidbody
            if (_isMovingFromAttachedRigidbody && (!isRigidbodyKinematic || colliderAttachedRigidbody == _attachedRigidbody)) {
                return false
            }

            // don't collide with dynamic rigidbodies if our RigidbodyInteractionType is kinematic
            if (rigidbodyInteractionType == RigidbodyInteractionType.Kinematic && !isRigidbodyKinematic) {
                // wake up rigidbody
                colliderAttachedRigidbody.wakeUp()

                return false
            }
        }

        // Custom checks
        let colliderValid = CharacterController!.IsColliderValidForCollisions(coll)
        if (!colliderValid) {
            return false
        }

        return true
    }

    /// Determines if the motor is considered stable on a given hit
    public func EvaluateHitStability(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3, atCharacterPosition: Vector3,
                                     atCharacterRotation: Quaternion, withCharacterVelocity: Vector3, stabilityReport: inout HitStabilityReport) {
        if (!_solveGrounding) {
            stabilityReport.IsStable = false
            return
        }

        let atCharacterUp = Vector3.transformByQuat(v: _cachedWorldUp, quaternion: atCharacterRotation)
        let innerHitDirection = Vector3.projectOnPlane(vector: hitNormal, planeNormal: atCharacterUp).normalized()

        stabilityReport.IsStable = IsStableOnNormal(hitNormal)

        stabilityReport.FoundInnerNormal = false
        stabilityReport.FoundOuterNormal = false
        stabilityReport.InnerNormal = hitNormal
        stabilityReport.OuterNormal = hitNormal

        // Ledge handling
        if (LedgeAndDenivelationHandling) {
            var ledgeCheckHeight = KinematicCharacterMotor.MinDistanceForLedge
            if (StepHandling != StepHandlingMethod.None) {
                ledgeCheckHeight = MaxStepHeight
            }

            var isStableLedgeInner = false
            var isStableLedgeOuter = false

            var innerLedgeHit = HitResult()
            if (CharacterCollisionsRaycast(
                    position: hitPoint + (atCharacterUp * KinematicCharacterMotor.SecondaryProbesVertical) + (innerHitDirection * KinematicCharacterMotor.SecondaryProbesHorizontal),
                    direction: -atCharacterUp,
                    distance: ledgeCheckHeight + KinematicCharacterMotor.SecondaryProbesVertical,
                    closestHit: &innerLedgeHit,
                    hits: _internalCharacterHits) > 0) {
                let innerLedgeNormal = innerLedgeHit.normal
                stabilityReport.InnerNormal = innerLedgeNormal
                stabilityReport.FoundInnerNormal = true
                isStableLedgeInner = IsStableOnNormal(innerLedgeNormal)
            }

            var outerLedgeHit = HitResult()
            if (CharacterCollisionsRaycast(
                    position: hitPoint + (atCharacterUp * KinematicCharacterMotor.SecondaryProbesVertical)
                            + (-innerHitDirection * KinematicCharacterMotor.SecondaryProbesHorizontal),
                    direction: -atCharacterUp,
                    distance: ledgeCheckHeight + KinematicCharacterMotor.SecondaryProbesVertical,
                    closestHit: &outerLedgeHit,
                    hits: _internalCharacterHits) > 0) {
                let outerLedgeNormal = outerLedgeHit.normal
                stabilityReport.OuterNormal = outerLedgeNormal
                stabilityReport.FoundOuterNormal = true
                isStableLedgeOuter = IsStableOnNormal(outerLedgeNormal)
            }

            stabilityReport.LedgeDetected = (isStableLedgeInner != isStableLedgeOuter)
            if (stabilityReport.LedgeDetected) {
                stabilityReport.IsOnEmptySideOfLedge = isStableLedgeOuter && !isStableLedgeInner
                stabilityReport.LedgeGroundNormal = isStableLedgeOuter ? stabilityReport.OuterNormal : stabilityReport.InnerNormal
                stabilityReport.LedgeRightDirection = Vector3.cross(left: hitNormal, right: stabilityReport.LedgeGroundNormal).normalized()
                stabilityReport.LedgeFacingDirection = Vector3.projectOnPlane(vector: Vector3.cross(left: stabilityReport.LedgeGroundNormal,
                        right: stabilityReport.LedgeRightDirection),
                        planeNormal: CharacterUp).normalized()
                stabilityReport.DistanceFromLedge =
                        Vector3.projectOnPlane(vector: (hitPoint - (atCharacterPosition + Vector3.transformByQuat(v: _characterTransformToCapsuleBottom,
                                quaternion: atCharacterRotation))),
                                planeNormal: atCharacterUp).length()
                stabilityReport.IsMovingTowardsEmptySideOfLedge = Vector3.dot(left: withCharacterVelocity.normalized(),
                        right: stabilityReport.LedgeFacingDirection) > 0
            }

            if (stabilityReport.IsStable) {
                stabilityReport.IsStable = IsStableWithSpecialCases(stabilityReport: &stabilityReport, velocity: withCharacterVelocity)
            }
        }

        // Step handling
        if (StepHandling != StepHandlingMethod.None && !stabilityReport.IsStable) {
            // Stepping not supported on dynamic rigidbodies
            let hitRigidbody = hitCollider as? DynamicCollider
            if (!(hitRigidbody != nil && !hitRigidbody!.isKinematic)) {
                DetectSteps(characterPosition: atCharacterPosition, characterRotation: atCharacterRotation,
                        hitPoint: hitPoint, innerHitDirection: innerHitDirection, stabilityReport: &stabilityReport)

                if (stabilityReport.ValidStepDetected) {
                    stabilityReport.IsStable = true
                }
            }
        }

        CharacterController!.ProcessHitStabilityReport(hitCollider: hitCollider, hitNormal: hitNormal, hitPoint: hitPoint,
                atCharacterPosition: atCharacterPosition, atCharacterRotation: atCharacterRotation,
                hitStabilityReport: &stabilityReport)
    }

    private func DetectSteps(characterPosition: Vector3, characterRotation: Quaternion, hitPoint: Vector3,
                             innerHitDirection: Vector3, stabilityReport: inout HitStabilityReport) {
        var nbStepHits = 0
        var tmpCollider: Collider? = nil
        var outerStepHit = HitResult()
        let characterUp: Vector3 = Vector3.transformByQuat(v: _cachedWorldUp, quaternion: characterRotation)
        let verticalCharToHit: Vector3 = Vector3.project(vector: (hitPoint - characterPosition), onNormal: characterUp)
        let horizontalCharToHitDirection: Vector3 = Vector3.projectOnPlane(vector: (hitPoint - characterPosition), planeNormal: characterUp).normalized()
        var stepCheckStartPos: Vector3 = (hitPoint - verticalCharToHit) + (characterUp * MaxStepHeight)
                + (horizontalCharToHitDirection * KinematicCharacterMotor.CollisionOffset * 3.0)

        // Do outer step check with capsule cast on hit point
        nbStepHits = CharacterCollisionsSweep(
                position: stepCheckStartPos,
                rotation: characterRotation,
                direction: -characterUp,
                distance: MaxStepHeight + KinematicCharacterMotor.CollisionOffset,
                closestHit: &outerStepHit,
                hits: _internalCharacterHits,
                inflate: 0,
                acceptOnlyStableGroundLayer: true)

        // Check for overlaps and obstructions at the hit position
        if (CheckStepValidity(nbStepHits: nbStepHits, characterPosition: characterPosition, characterRotation: characterRotation,
                innerHitDirection: innerHitDirection, stepCheckStartPos: stepCheckStartPos, hitCollider: &tmpCollider)) {
            stabilityReport.ValidStepDetected = true
            stabilityReport.SteppedCollider = tmpCollider!
        }

        if (StepHandling == StepHandlingMethod.Extra && !stabilityReport.ValidStepDetected) {
            // Do min reach step check with capsule cast on hit point
            stepCheckStartPos = characterPosition + (characterUp * MaxStepHeight) + (-innerHitDirection * MinRequiredStepDepth)
            nbStepHits = CharacterCollisionsSweep(
                    position: stepCheckStartPos,
                    rotation: characterRotation,
                    direction: -characterUp,
                    distance: MaxStepHeight - KinematicCharacterMotor.CollisionOffset,
                    closestHit: &outerStepHit,
                    hits: _internalCharacterHits,
                    inflate: 0,
                    acceptOnlyStableGroundLayer: true)

            // Check for overlaps and obstructions at the hit position
            if (CheckStepValidity(nbStepHits: nbStepHits, characterPosition: characterPosition, characterRotation: characterRotation,
                    innerHitDirection: innerHitDirection, stepCheckStartPos: stepCheckStartPos, hitCollider: &tmpCollider)) {
                stabilityReport.ValidStepDetected = true
                stabilityReport.SteppedCollider = tmpCollider!
            }
        }
    }

    private func CheckStepValidity(nbStepHits: Int, characterPosition: Vector3, characterRotation: Quaternion,
                                   innerHitDirection: Vector3, stepCheckStartPos: Vector3, hitCollider: inout Collider?) -> Bool {
        hitCollider = nil
        let characterUp = Vector3.transformByQuat(v: Vector3.up, quaternion: characterRotation)

        // Find the farthest valid hit for stepping
        var foundValidStepPosition = false
        var nbStepHits = nbStepHits
        while (nbStepHits > 0 && !foundValidStepPosition) {
            // Get farthest hit among the remaining hits
            var farthestHit = HitResult()
            var farthestDistance: Float = 0
            var farthestIndex: Int = 0
            for i in 0..<nbStepHits {
                let hitDistance = _internalCharacterHits[i].distance
                if (hitDistance > farthestDistance) {
                    farthestDistance = hitDistance
                    farthestHit = _internalCharacterHits[i]
                    farthestIndex = i
                }
            }

            let characterPositionAtHit = stepCheckStartPos + (-characterUp * (farthestHit.distance - KinematicCharacterMotor.CollisionOffset))

            let atStepOverlaps = CharacterCollisionsOverlap(position: characterPositionAtHit, rotation: characterRotation,
                    overlappedColliders: _internalProbedColliders)
            if (atStepOverlaps <= 0) {
                // Check for outer hit slope normal stability at the step position
                var outerSlopeHit = HitResult()
                if (CharacterCollisionsRaycast(
                        position: farthestHit.point + (characterUp * KinematicCharacterMotor.SecondaryProbesVertical)
                                + (-innerHitDirection * KinematicCharacterMotor.SecondaryProbesHorizontal),
                        direction: -characterUp,
                        distance: MaxStepHeight + KinematicCharacterMotor.SecondaryProbesVertical,
                        closestHit: &outerSlopeHit,
                        hits: _internalCharacterHits,
                        acceptOnlyStableGroundLayer: true) > 0) {
                    if (IsStableOnNormal(outerSlopeHit.normal)) {
                        var tmpUpObstructionHit = HitResult()
                        // Cast upward to detect any obstructions to moving there
                        if (CharacterCollisionsSweep(
                                position: characterPosition, // position
                                rotation: characterRotation, // rotation
                                direction: characterUp, // direction
                                distance: MaxStepHeight - farthestHit.distance, // distance
                                closestHit: &tmpUpObstructionHit, // closest hit
                                hits: _internalCharacterHits) // all hits
                                <= 0) {
                            // Do inner step check...
                            var innerStepValid = false
                            var innerStepHit = HitResult()

                            if (AllowSteppingWithoutStableGrounding) {
                                innerStepValid = true
                            } else {
                                // At the capsule center at the step height
                                if (CharacterCollisionsRaycast(
                                        position: characterPosition + Vector3.project(vector: (characterPositionAtHit - characterPosition), onNormal: characterUp),
                                        direction: -characterUp,
                                        distance: MaxStepHeight,
                                        closestHit: &innerStepHit,
                                        hits: _internalCharacterHits,
                                        acceptOnlyStableGroundLayer: true) > 0) {
                                    if (IsStableOnNormal(innerStepHit.normal)) {
                                        innerStepValid = true
                                    }
                                }
                            }

                            if (!innerStepValid) {
                                // At inner step of the step point
                                if (CharacterCollisionsRaycast(
                                        position: farthestHit.point + (innerHitDirection * KinematicCharacterMotor.SecondaryProbesHorizontal),
                                        direction: -characterUp,
                                        distance: MaxStepHeight,
                                        closestHit: &innerStepHit,
                                        hits: _internalCharacterHits,
                                        acceptOnlyStableGroundLayer: true) > 0) {
                                    if (IsStableOnNormal(innerStepHit.normal)) {
                                        innerStepValid = true
                                    }
                                }
                            }

                            // Final validation of step
                            if (innerStepValid) {
                                hitCollider = farthestHit.collider
                                foundValidStepPosition = true
                                return true
                            }
                        }
                    }
                }
            }

            // Discard hit if not valid step
            if (!foundValidStepPosition) {
                nbStepHits -= 1
                if (farthestIndex < nbStepHits) {
                    _internalCharacterHits[farthestIndex] = _internalCharacterHits[nbStepHits]
                }
            }
        }

        return false
    }

    /// Get true linear velocity (taking into account rotational velocity) on a given point of a rigidbody
    public func GetVelocityFromRigidbodyMovement(interactiveRigidbody: DynamicCollider, atPoint: Vector3, deltaTime: Float,
                                                 linearVelocity: inout Vector3, angularVelocity: inout Vector3) {
        if (deltaTime > 0) {
            linearVelocity = interactiveRigidbody.linearVelocity
            angularVelocity = interactiveRigidbody.angularVelocity
            if (interactiveRigidbody.isKinematic) {
                if let physicsMover = interactiveRigidbody.entity.getComponent(PhysicsMover.self) {
                    linearVelocity = physicsMover.Velocity
                    angularVelocity = physicsMover.AngularVelocity
                }
            }

            if angularVelocity != Vector3.zero {
                let centerOfRotation = Vector3.transformCoordinate(v: interactiveRigidbody.centerOfMass,
                        m: interactiveRigidbody.entity.transform.worldMatrix)
                let centerOfRotationToPoint = atPoint - centerOfRotation
                let euler = angularVelocity * MathUtil.radToDegreeFactor * deltaTime
                let rotationFromInteractiveRigidbody = Quaternion.rotationEuler(x: euler.x, y: euler.y, z: euler.z)
                let finalPointPosition = centerOfRotation + Vector3.transformByQuat(v: centerOfRotationToPoint, quaternion: rotationFromInteractiveRigidbody)
                linearVelocity += (finalPointPosition - atPoint) / deltaTime
            }
        } else {
            linearVelocity = Vector3()
            angularVelocity = Vector3()
            return
        }
    }

    /// Determines if a collider has an attached interactive rigidbody
    private func GetInteractiveRigidbody(onCollider: Collider) -> DynamicCollider? {
        let colliderAttachedRigidbody = onCollider as? DynamicCollider
        if let colliderAttachedRigidbody = colliderAttachedRigidbody {
            if colliderAttachedRigidbody.entity.getComponent(PhysicsMover.self) != nil {
                return colliderAttachedRigidbody
            }

            if (!colliderAttachedRigidbody.isKinematic) {
                return colliderAttachedRigidbody
            }
        }
        return nil
    }

    /// Calculates the velocity required to move the character to the target position over a specific deltaTime.
    /// Useful for when you wish to work with positions rather than velocities in the UpdateVelocity callback
    public func GetVelocityForMovePosition(fromPosition: Vector3, toPosition: Vector3, deltaTime: Float) -> Vector3 {
        return GetVelocityFromMovement(movement: toPosition - fromPosition, deltaTime: deltaTime)
    }

    public func GetVelocityFromMovement(movement: Vector3, deltaTime: Float) -> Vector3 {
        if (deltaTime <= 0) {
            return Vector3.zero
        }

        return movement / deltaTime
    }

    /// Trims a vector to make it restricted against a plane
    private func RestrictVectorToPlane(vector: inout Vector3, toPlane: Vector3) {
        if (vector.x > 0.0) != (toPlane.x > 0.0) {
            vector.x = 0
        }
        if (vector.y > 0) != (toPlane.y > 0) {
            vector.y = 0
        }
        if (vector.z > 0) != (toPlane.z > 0) {
            vector.z = 0
        }
    }
}

// MARK: - Scene Query
extension KinematicCharacterMotor {
    /// Detect if the character capsule is overlapping with anything collidable
    /// - Parameters:
    ///   - position: position
    ///   - rotation: rotation
    ///   - overlappedColliders: overlappedColliders
    ///   - inflate: inflate
    ///   - acceptOnlyStableGroundLayer: acceptOnlyStableGroundLayer
    /// - Returns: Returns number of overlaps
    public func CharacterCollisionsOverlap(position: Vector3, rotation: Quaternion, overlappedColliders: [Collider?],
                                           inflate: Float = 0, acceptOnlyStableGroundLayer: Bool = false) -> Int {
        var queryLayers = CollidableLayers
        if (acceptOnlyStableGroundLayer) {
            queryLayers = [CollidableLayers, StableGroundLayers]
        }

        var bottom = position + Vector3.transformByQuat(v: _characterTransformToCapsuleBottomHemi, quaternion: rotation)
        var top = position + Vector3.transformByQuat(v: _characterTransformToCapsuleTopHemi, quaternion: rotation)
        if (inflate != 0) {
            bottom += Vector3.transformByQuat(v: Vector3.down, quaternion: rotation) * inflate
            top += Vector3.transformByQuat(v: Vector3.up, quaternion: rotation) * inflate
        }

        var nbHits = 0
        let shape = CapsuleColliderShape()
        shape.radius = (Capsule!.shapes[0] as! CapsuleColliderShape).radius + inflate
        // todo
        var overlappedColliders = engine.physicsManager.overlapAll(shape: shape, origin: (bottom + top) * 0.5, rotation: Quaternion(), layerMask: queryLayers)

        // Filter out invalid colliders
        nbHits = overlappedColliders.count
        for i in stride(from: overlappedColliders.count - 1, to: 0, by: -1) {
            if (!CheckIfColliderValidForCollisions(overlappedColliders[i].collider!)) {
                nbHits -= 1
                if (i < nbHits) {
                    overlappedColliders[i] = overlappedColliders[nbHits]
                }
            }
        }

        return nbHits
    }

    /// Detect if the character capsule is overlapping with anything
    /// - Parameters:
    ///   - position: position
    ///   - rotation: rotation
    ///   - overlappedColliders: overlappedColliders
    ///   - layers: layers
    ///   - triggerInteraction: triggerInteraction
    ///   - inflate: inflate
    /// - Returns: Returns number of overlaps
    public func CharacterOverlap(position: Vector3, rotation: Quaternion, overlappedColliders: [Collider?],
                                 layers: Layer, inflate: Float = 0) -> Int {
        var bottom = position + Vector3.transformByQuat(v: _characterTransformToCapsuleBottomHemi, quaternion: rotation)
        var top = position + Vector3.transformByQuat(v: _characterTransformToCapsuleTopHemi, quaternion: rotation)
        if (inflate != 0) {
            bottom += Vector3.transformByQuat(v: Vector3.down, quaternion: rotation) * inflate
            top += Vector3.transformByQuat(v: Vector3.up, quaternion: rotation) * inflate
        }

        var nbHits = 0
        let shape = CapsuleColliderShape()
        shape.radius = (Capsule!.shapes[0] as! CapsuleColliderShape).radius + inflate
        // todo
        var overlappedColliders = engine.physicsManager.overlapAll(shape: shape, origin: (bottom + top) * 0.5, rotation: Quaternion(), layerMask: layers)

        // Filter out the character capsule itself
        nbHits = overlappedColliders.count
        for i in stride(from: overlappedColliders.count - 1, to: 0, by: -1) {
            if (overlappedColliders[i].collider === Capsule) {
                nbHits -= 1
                if (i < nbHits) {
                    overlappedColliders[i] = overlappedColliders[nbHits]
                }
            }
        }

        return nbHits
    }

    /// Sweeps the capsule's volume to detect collision hits
    /// - Parameters:
    ///   - position: position
    ///   - rotation: rotation
    ///   - direction: direction
    ///   - distance: distance
    ///   - closestHit: closestHit
    ///   - hits: hits
    ///   - inflate: inflate
    ///   - acceptOnlyStableGroundLayer: acceptOnlyStableGroundLayer
    /// - Returns: Returns the number of hits
    public func CharacterCollisionsSweep(position: Vector3, rotation: Quaternion, direction: Vector3, distance: Float,
                                         closestHit: inout HitResult, hits: [HitResult], inflate: Float = 0,
                                         acceptOnlyStableGroundLayer: Bool = false) -> Int {
        var queryLayers = CollidableLayers
        if (acceptOnlyStableGroundLayer) {
            queryLayers = [CollidableLayers, StableGroundLayers]
        }

        var bottom = position + Vector3.transformByQuat(v: _characterTransformToCapsuleBottomHemi, quaternion: rotation)
                - (direction * KinematicCharacterMotor.SweepProbingBackstepDistance)
        var top = position + Vector3.transformByQuat(v: _characterTransformToCapsuleTopHemi, quaternion: rotation)
                - (direction * KinematicCharacterMotor.SweepProbingBackstepDistance)
        if (inflate != 0) {
            bottom += Vector3.transformByQuat(v: Vector3.down, quaternion: rotation) * inflate
            top += Vector3.transformByQuat(v: Vector3.up, quaternion: rotation) * inflate
        }

        // Capsule cast
        var nbHits = 0
        let shape = CapsuleColliderShape()
        shape.radius = (Capsule!.shapes[0] as! CapsuleColliderShape).radius + inflate
        var hits = engine.physicsManager.sweepAll(shape: shape, position: (bottom + top) * 0.5, rotation: Quaternion(),
                dir: direction, distance: distance + KinematicCharacterMotor.SweepProbingBackstepDistance,
                layerMask: queryLayers)

        // Hits filter
        closestHit = HitResult()
        var closestDistance = Float.infinity
        nbHits = hits.count
        for i in stride(from: hits.count - 1, to: 0, by: -1) {
            hits[i].distance -= KinematicCharacterMotor.SweepProbingBackstepDistance

            let hit = hits[i]
            let hitDistance = hit.distance

            // Filter out the invalid hits
            if (hitDistance <= 0 || !CheckIfColliderValidForCollisions(hit.collider!)) {
                nbHits -= 1
                if (i < nbHits) {
                    hits[i] = hits[nbHits]
                }
            } else {
                // Remember closest valid hit
                if (hitDistance < closestDistance) {
                    closestHit = hit
                    closestDistance = hitDistance
                }
            }
        }

        return nbHits
    }

    /// Sweeps the capsule's volume to detect hits
    /// - Parameters:
    ///   - position: position
    ///   - rotation: rotation
    ///   - direction: direction
    ///   - distance: distance
    ///   - closestHit: closestHit
    ///   - hits: hits
    ///   - layers: layers
    ///   - inflate: inflate
    /// - Returns: Returns the number of hits
    public func CharacterSweep(position: Vector3, rotation: Quaternion, direction: Vector3, distance: Float,
                               closestHit: inout HitResult, hits: [HitResult], layers: Layer, inflate: Float = 0) -> Int {
        closestHit = HitResult()

        var bottom = position + Vector3.transformByQuat(v: _characterTransformToCapsuleBottomHemi, quaternion: rotation)
        var top = position + Vector3.transformByQuat(v: _characterTransformToCapsuleTopHemi, quaternion: rotation)
        if (inflate != 0) {
            bottom += Vector3.transformByQuat(v: Vector3.down, quaternion: rotation) * inflate
            top += Vector3.transformByQuat(v: Vector3.up, quaternion: rotation) * inflate
        }

        // Capsule cast
        var nbHits = 0
        let shape = CapsuleColliderShape()
        shape.radius = (Capsule!.shapes[0] as! CapsuleColliderShape).radius + inflate
        var hits = engine.physicsManager.sweepAll(shape: shape, position: (bottom + top) * 0.5, rotation: Quaternion(),
                dir: direction, distance: distance, layerMask: layers)

        // Hits filter
        var closestDistance = Float.infinity
        nbHits = hits.count
        for i in stride(from: hits.count - 1, to: 0, by: -1) {
            let hit = hits[i]

            // Filter out the character capsule
            if (hit.distance <= 0 || hit.collider == Capsule) {
                nbHits -= 1
                if (i < nbHits) {
                    hits[i] = hits[nbHits]
                }
            } else {
                // Remember closest valid hit
                let hitDistance = hit.distance
                if (hitDistance < closestDistance) {
                    closestHit = hit
                    closestDistance = hitDistance
                }
            }
        }

        return nbHits
    }

    /// Casts the character volume in the character's downward direction to detect ground
    /// - Parameters:
    ///   - position: position
    ///   - rotation: rotation
    ///   - direction: direction
    ///   - distance: distance
    ///   - closestHit: closestHit
    /// - Returns: Returns the number of hits
    private func CharacterGroundSweep(position: Vector3, rotation: Quaternion, direction: Vector3,
                                      distance: Float, closestHit: inout HitResult) -> Bool {
        closestHit = HitResult()

        // Capsule cast
        let capsule = CapsuleColliderShape()
        capsule.radius = (Capsule!.shapes[0] as! CapsuleColliderShape).radius
        capsule.rotation = rotation.toEuler()
        capsule.position = -direction * KinematicCharacterMotor.GroundProbingBackstepDistance // todo
        let _internalCharacterHits = engine.physicsManager.sweepAll(shape: capsule, position: position, rotation: Quaternion(),
                dir: direction, distance: distance + KinematicCharacterMotor.GroundProbingBackstepDistance,
                layerMask: [CollidableLayers, StableGroundLayers])

        // Hits filter
        var foundValidHit = false
        var closestDistance = Float.infinity
        for i in 0..<_internalCharacterHits.count {
            let hit = _internalCharacterHits[i]
            let hitDistance = hit.distance

            // Find the closest valid hit
            if (hitDistance > 0 && CheckIfColliderValidForCollisions(hit.collider!)) {
                if (hitDistance < closestDistance) {
                    closestHit = hit
                    closestHit.distance -= KinematicCharacterMotor.GroundProbingBackstepDistance
                    closestDistance = hitDistance

                    foundValidHit = true
                }
            }
        }

        return foundValidHit
    }

    /// Raycasts to detect collision hits
    /// - Parameters:
    ///   - position: position
    ///   - direction: direction
    ///   - distance: distance
    ///   - closestHit: closestHit
    ///   - hits: hits
    ///   - acceptOnlyStableGroundLayer: acceptOnlyStableGroundLayer
    /// - Returns: Returns the number of hits
    public func CharacterCollisionsRaycast(position: Vector3, direction: Vector3, distance: Float,
                                           closestHit: inout HitResult, hits: [HitResult], acceptOnlyStableGroundLayer: Bool = false) -> Int {
        var queryLayers = CollidableLayers
        if (acceptOnlyStableGroundLayer) {
            queryLayers = [CollidableLayers, StableGroundLayers]
        }

        // Raycast
        var nbHits = 0
        var hits = engine.physicsManager.raycastAll(Ray(origin: position, direction: direction), distance: distance, layerMask: queryLayers)

        // Hits filter
        closestHit = HitResult()
        var closestDistance = Float.infinity
        nbHits = hits.count
        for i in stride(from: hits.count - 1, to: 0, by: -1) {
            let hit = hits[i]
            let hitDistance = hit.distance

            // Filter out the invalid hits
            if (hitDistance <= 0 || !CheckIfColliderValidForCollisions(hit.collider!)) {
                nbHits -= 1
                if (i < nbHits) {
                    hits[i] = hits[nbHits]
                }
            } else {
                // Remember closest valid hit
                if (hitDistance < closestDistance) {
                    closestHit = hit
                    closestDistance = hitDistance
                }
            }
        }

        return nbHits
    }
}
