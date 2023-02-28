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
    public var Position: Vector3
    public var Rotation: Quaternion
    public var BaseVelocity: Vector3

    public var MustUnground: Bool
    public var MustUngroundTime: Float
    public var LastMovementIterationFoundAnyGround: Bool
    public var GroundingStatus: CharacterTransientGroundingReport

    public var AttachedRigidbody: DynamicCollider
    public var AttachedRigidbodyVelocity: Vector3
}

/// Describes an overlap between the character capsule and another collider
public struct OverlapResult {
    public var Normal: Vector3
    public var Collider: Collider

    public init(normal: Vector3, collider: Collider) {
        Normal = normal
        Collider = collider
    }
}

/// Contains all the information for the motor's grounding status
public struct CharacterGroundingReport {
    public var FoundAnyGround: Bool
    public var IsStableOnGround: Bool
    public var SnappingPrevented: Bool
    public var GroundNormal: Vector3
    public var InnerGroundNormal: Vector3
    public var OuterGroundNormal: Vector3

    public var GroundCollider: Collider?
    public var GroundPoint: Vector3

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
    public var FoundAnyGround: Bool
    public var IsStableOnGround: Bool
    public var SnappingPrevented: Bool
    public var GroundNormal: Vector3
    public var InnerGroundNormal: Vector3
    public var OuterGroundNormal: Vector3

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
    public var IsStable: Bool

    public var FoundInnerNormal: Bool
    public var InnerNormal: Vector3
    public var FoundOuterNormal: Bool
    public var OuterNormal: Vector3

    public var ValidStepDetected: Bool
    public var SteppedCollider: Collider

    public var LedgeDetected: Bool
    public var IsOnEmptySideOfLedge: Bool
    public var DistanceFromLedge: Float
    public var IsMovingTowardsEmptySideOfLedge: Bool
    public var LedgeGroundNormal: Vector3
    public var LedgeRightDirection: Vector3
    public var LedgeFacingDirection: Vector3
}

/// Contains the information of hit rigidbodies during the movement phase, so they can be processed afterwards
public struct RigidbodyProjectionHit {
    public var Rigidbody: DynamicCollider
    public var HitPoint: Vector3
    public var EffectiveHitNormal: Vector3
    public var HitVelocity: Vector3
    public var StableOnHit: Bool
}
