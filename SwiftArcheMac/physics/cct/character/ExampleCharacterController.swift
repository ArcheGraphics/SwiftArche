//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public enum CharacterState {
    case Default
}

public enum OrientationMethod {
    case TowardsCamera
    case TowardsMovement
}

public struct PlayerCharacterInputs {
    public var MoveAxisForward: Float = 0
    public var MoveAxisRight: Float = 0
    public var CameraRotation = Quaternion()
    public var JumpDown: Bool = false
    public var CrouchDown: Bool = false
    public var CrouchUp: Bool = false
}

public struct AICharacterInputs {
    public var MoveVector = Vector3()
    public var LookVector = Vector3()
}

public enum BonusOrientationMethod {
    case None
    case TowardsGravity
    case TowardsGroundSlopeAndGravity
}

public class ExampleCharacterController: Script {
    public var Motor: KinematicCharacterMotor?

    //MARK: -"Stable Movement"
    public var MaxStableMoveSpeed: Float = 10
    public var StableMovementSharpness: Float = 15
    public var OrientationSharpness: Float = 10
    public var orientationMethod = OrientationMethod.TowardsCamera

    //MARK: -"Air Movement"
    public var MaxAirMoveSpeed: Float = 15
    public var AirAccelerationSpeed: Float = 15
    public var Drag: Float = 0.1

    //MARK: -"Jumping"
    public var AllowJumpingWhenSliding = false
    public var JumpUpSpeed: Float = 10
    public var JumpScalableForwardSpeed: Float = 10
    public var JumpPreGroundingGraceTime: Float = 0
    public var JumpPostGroundingGraceTime: Float = 0

    //MARK: -"Misc"
    public var IgnoredColliders: [Collider] = []
    public var bonusOrientationMethod = BonusOrientationMethod.None
    public var BonusOrientationSharpness: Float = 10
    public var Gravity = Vector3(0, -30, 0)
    public var MeshRoot: Transform?
    public var CameraFollowPoint: Transform?
    public var CrouchedCapsuleHeight: Float = 1

    public var CurrentCharacterState = CharacterState.Default

    private var _probedColliders = [Collider?](repeating: nil, count: 8)
    private var _probedHits = [HitResult](repeating: HitResult(), count: 8)
    private var _moveInputVector = Vector3()
    private var _lookInputVector = Vector3()
    private var _jumpRequested = false
    private var _jumpConsumed = false
    private var _jumpedThisFrame = false
    private var _timeSinceJumpRequested: Float = Float.infinity
    private var _timeSinceLastAbleToJump: Float = 0
    private var _internalVelocityAdd = Vector3.zero
    private var _shouldBeCrouching = false
    private var _isCrouching = false

    private var lastInnerNormal = Vector3.zero
    private var lastOuterNormal = Vector3.zero

    public override func onAwake() {
        // Handle initial state
        TransitionToState(CharacterState.Default)

        // Assign the characterController to the motor
        Motor?.CharacterController = self
    }

    /// Handles movement state transitions and enter/exit callbacks
    public func TransitionToState(_ newState: CharacterState) {
        let tmpInitialState = CurrentCharacterState
        OnStateExit(state: tmpInitialState, toState: newState)
        CurrentCharacterState = newState
        OnStateEnter(state: newState, fromState: tmpInitialState)
    }

    /// Event when entering a state
    public func OnStateEnter(state: CharacterState, fromState: CharacterState) {
        switch (state) {
        case CharacterState.Default:
            break
        }
    }

    /// Event when exiting a state
    public func OnStateExit(state: CharacterState, toState: CharacterState) {
        switch (state) {
        case CharacterState.Default:
            break
        }
    }

    /// This is called every frame by ExamplePlayer in order to tell the character what its inputs are
    public func SetInputs(_ inputs: inout PlayerCharacterInputs) {
        // Clamp input
        let moveInputVector = Vector3.clampMagnitude(vector: Vector3(inputs.MoveAxisRight, 0, inputs.MoveAxisForward), maxLength: 1)

        // Calculate camera direction and rotation on the character plane
        var cameraPlanarDirection = Vector3.projectOnPlane(vector: Vector3.transformByQuat(v: Vector3.forward, quaternion: inputs.CameraRotation),
                planeNormal: Motor!.CharacterUp).normalized()
        if (cameraPlanarDirection.lengthSquared() == 0) {
            cameraPlanarDirection = Vector3.projectOnPlane(vector: Vector3.transformByQuat(v: Vector3.up, quaternion: inputs.CameraRotation),
                    planeNormal: Motor!.CharacterUp).normalized()
        }
        let cameraPlanarRotation = Matrix.lookAt(eye: Vector3(), target: cameraPlanarDirection, up: Motor!.CharacterUp).getRotation()

        switch (CurrentCharacterState) {
        case CharacterState.Default:

            // Move and look inputs
            _moveInputVector = Vector3.transformByQuat(v: moveInputVector, quaternion: cameraPlanarRotation)

            switch (orientationMethod) {
            case OrientationMethod.TowardsCamera:
                _lookInputVector = cameraPlanarDirection
                break
            case OrientationMethod.TowardsMovement:
                _lookInputVector = _moveInputVector.normalized()
                break
            }

            // Jumping input
            if (inputs.JumpDown) {
                _timeSinceJumpRequested = 0
                _jumpRequested = true
            }

            // Crouching input
            if (inputs.CrouchDown) {
                _shouldBeCrouching = true

                if (!_isCrouching) {
                    _isCrouching = true
                    Motor!.SetCapsuleDimensions(radius: 0.5, height: CrouchedCapsuleHeight, yOffset: CrouchedCapsuleHeight * 0.5)
                    MeshRoot!.scale = Vector3(1, 0.5, 1)
                }
            } else if (inputs.CrouchUp) {
                _shouldBeCrouching = false
            }

            break

        }
    }

    /// This is called every frame by the AI script in order to tell the character what its inputs are
    public func SetInputs(_ inputs: AICharacterInputs) {
        _moveInputVector = inputs.MoveVector
        _lookInputVector = inputs.LookVector
    }

    private var _tmpTransientRot = Quaternion()

    public func AddVelocity(_ velocity: Vector3) {
        switch (CurrentCharacterState) {
        case CharacterState.Default:
            _internalVelocityAdd += velocity
            break
        }
    }

    func OnLanded() {
    }

    func OnLeaveStableGround() {
    }
}

extension ExampleCharacterController: ICharacterController {
    public func UpdateRotation(currentRotation: inout Quaternion, deltaTime: Float) {
        switch (CurrentCharacterState) {
        case CharacterState.Default:
            if (_lookInputVector.lengthSquared() > 0 && OrientationSharpness > 0) {
                // Smoothly interpolate from current to target look direction
                let smoothedLookInputDirection = Vector3.lerp(left: Motor!.CharacterForward, right: _lookInputVector,
                        t: 1 - exp(-OrientationSharpness * deltaTime)).normalized()

                // Set the current rotation (which will be used by the KinematicCharacterMotor)
                currentRotation = Matrix.lookAt(eye: Vector3(), target: smoothedLookInputDirection, up: Motor!.CharacterUp).getRotation()
            }

            let currentUp = Vector3.transformByQuat(v: Vector3.up, quaternion: currentRotation)
            if (bonusOrientationMethod == BonusOrientationMethod.TowardsGravity) {
                // Rotate from current up to invert gravity
                let smoothedGravityDir = Vector3.lerp(left: currentUp, right: -Gravity.normalized(), t: 1 - exp(-BonusOrientationSharpness * deltaTime))
                currentRotation = Quaternion.shortestRotation(from: currentUp, target: smoothedGravityDir) * currentRotation
            } else if (bonusOrientationMethod == BonusOrientationMethod.TowardsGroundSlopeAndGravity) {
                if (Motor!.GroundingStatus.IsStableOnGround) {
                    let radius = (Motor!.Capsule!.shapes[0] as! CapsuleColliderShape).radius
                    let initialCharacterBottomHemiCenter = Motor!.TransientPosition + (currentUp * radius)

                    let smoothedGroundNormal = Vector3.lerp(left: Motor!.CharacterUp, right: Motor!.GroundingStatus.GroundNormal,
                            t: 1 - exp(-BonusOrientationSharpness * deltaTime))
                    currentRotation = Quaternion.shortestRotation(from: currentUp, target: smoothedGroundNormal) * currentRotation

                    // Move the position to create a rotation around the bottom hemi center instead of around the pivot
                    Motor!.SetTransientPosition(initialCharacterBottomHemiCenter + (Vector3.transformByQuat(v: Vector3.down, quaternion: currentRotation) * radius))
                } else {
                    let smoothedGravityDir = Vector3.lerp(left: currentUp, right: -Gravity.normalized(), t: 1 - exp(-BonusOrientationSharpness * deltaTime))
                    currentRotation = Quaternion.shortestRotation(from: currentUp, target: smoothedGravityDir) * currentRotation
                }
            } else {
                let smoothedGravityDir = Vector3.lerp(left: currentUp, right: Vector3.up, t: 1 - exp(-BonusOrientationSharpness * deltaTime))
                currentRotation = Quaternion.shortestRotation(from: currentUp, target: smoothedGravityDir) * currentRotation
            }
            break
        }
    }

    public func UpdateVelocity(currentVelocity: inout Vector3, deltaTime: Float) {
        if let Motor = Motor {
            switch (CurrentCharacterState) {
            case CharacterState.Default:
                // Ground movement
                if (Motor.GroundingStatus.IsStableOnGround) {
                    let currentVelocityMagnitude = currentVelocity.length()

                    let effectiveGroundNormal = Motor.GroundingStatus.GroundNormal

                    // Reorient velocity on slope
                    currentVelocity = Motor.GetDirectionTangentToSurface(direction: currentVelocity, surfaceNormal: effectiveGroundNormal) * currentVelocityMagnitude

                    // Calculate target velocity
                    let inputRight = Vector3.cross(left: _moveInputVector, right: Motor.CharacterUp)
                    let reorientedInput = Vector3.cross(left: effectiveGroundNormal, right: inputRight).normalized() * _moveInputVector.length()
                    let targetMovementVelocity = reorientedInput * MaxStableMoveSpeed

                    // Smooth movement Velocity
                    currentVelocity = Vector3.lerp(left: currentVelocity, right: targetMovementVelocity,
                            t: 1 - exp(-StableMovementSharpness * deltaTime))
                }
                // Air movement
                else {
                    // Add move input
                    if (_moveInputVector.lengthSquared() > 0) {
                        var addedVelocity = _moveInputVector * AirAccelerationSpeed * deltaTime

                        let currentVelocityOnInputsPlane = Vector3.projectOnPlane(vector: currentVelocity, planeNormal: Motor.CharacterUp)

                        // Limit air velocity from inputs
                        if (currentVelocityOnInputsPlane.length() < MaxAirMoveSpeed) {
                            // clamp addedVel to make total vel not exceed max vel on inputs plane
                            let newTotal = Vector3.clampMagnitude(vector: currentVelocityOnInputsPlane + addedVelocity, maxLength: MaxAirMoveSpeed)
                            addedVelocity = newTotal - currentVelocityOnInputsPlane
                        } else {
                            // Make sure added vel doesn't go in the direction of the already-exceeding velocity
                            if (Vector3.dot(left: currentVelocityOnInputsPlane, right: addedVelocity) > 0) {
                                addedVelocity = Vector3.projectOnPlane(vector: addedVelocity,
                                        planeNormal: currentVelocityOnInputsPlane.normalized())
                            }
                        }

                        // Prevent air-climbing sloped walls
                        if (Motor.GroundingStatus.FoundAnyGround) {
                            if (Vector3.dot(left: currentVelocity + addedVelocity, right: addedVelocity) > 0) {
                                let perpenticularObstructionNormal = Vector3.cross(left: Vector3.cross(left: Motor.CharacterUp,
                                        right: Motor.GroundingStatus.GroundNormal), right: Motor.CharacterUp).normalized()
                                addedVelocity = Vector3.projectOnPlane(vector: addedVelocity, planeNormal: perpenticularObstructionNormal)
                            }
                        }

                        // Apply added velocity
                        currentVelocity += addedVelocity
                    }

                    // Gravity
                    currentVelocity += Gravity * deltaTime

                    // Drag
                    currentVelocity *= (1.0 / (1.0 + (Drag * deltaTime)))
                }

                // Handle jumping
                _jumpedThisFrame = false
                _timeSinceJumpRequested += deltaTime
                if (_jumpRequested) {
                    // See if we actually are allowed to jump
                    if (!_jumpConsumed && ((AllowJumpingWhenSliding ? Motor.GroundingStatus.FoundAnyGround : Motor.GroundingStatus.IsStableOnGround)
                            || _timeSinceLastAbleToJump <= JumpPostGroundingGraceTime)) {
                        // Calculate jump direction before ungrounding
                        var jumpDirection = Motor.CharacterUp
                        if (Motor.GroundingStatus.FoundAnyGround && !Motor.GroundingStatus.IsStableOnGround) {
                            jumpDirection = Motor.GroundingStatus.GroundNormal
                        }

                        // Makes the character skip ground probing/snapping on its next update.
                        // If this line weren't here, the character would remain snapped to the ground when trying to jump. Try commenting this line out and see.
                        Motor.ForceUnground()

                        // Add to the return velocity and reset jump state
                        currentVelocity += (jumpDirection * JumpUpSpeed) - Vector3.project(vector: currentVelocity, onNormal: Motor.CharacterUp)
                        currentVelocity += (_moveInputVector * JumpScalableForwardSpeed)
                        _jumpRequested = false
                        _jumpConsumed = true
                        _jumpedThisFrame = true
                    }
                }

                // Take into account additive velocity
                if (_internalVelocityAdd.lengthSquared() > 0) {
                    currentVelocity += _internalVelocityAdd
                    _internalVelocityAdd = Vector3.zero
                }
                break
            }
        }
    }

    public func BeforeCharacterUpdate(deltaTime: Float) {

    }

    public func PostGroundingUpdate(deltaTime: Float) {
        if let Motor = Motor {
            // Handle landing and leaving ground
            if (Motor.GroundingStatus.IsStableOnGround && !Motor.LastGroundingStatus.IsStableOnGround) {
                OnLanded()
            } else if (!Motor.GroundingStatus.IsStableOnGround && Motor.LastGroundingStatus.IsStableOnGround) {
                OnLeaveStableGround()
            }
        }
    }

    public func AfterCharacterUpdate(deltaTime: Float) {
        if let Motor = Motor {
            switch (CurrentCharacterState) {
            case CharacterState.Default:
                // Handle jump-related values
                // Handle jumping pre-ground grace period
                if (_jumpRequested && _timeSinceJumpRequested > JumpPreGroundingGraceTime) {
                    _jumpRequested = false
                }

                if (AllowJumpingWhenSliding ? Motor.GroundingStatus.FoundAnyGround : Motor.GroundingStatus.IsStableOnGround) {
                    // If we're on a ground surface, reset jumping values
                    if (!_jumpedThisFrame) {
                        _jumpConsumed = false
                    }
                    _timeSinceLastAbleToJump = 0
                } else {
                    // Keep track of time since we were last able to jump (for grace period)
                    _timeSinceLastAbleToJump += deltaTime
                }


                // Handle uncrouching
                if (_isCrouching && !_shouldBeCrouching) {
                    // Do an overlap test with the character's standing height to see if there are any obstructions
                    Motor.SetCapsuleDimensions(radius: 0.5, height: 2, yOffset: 1)
                    if (Motor.CharacterOverlap(
                            position: Motor.TransientPosition,
                            rotation: Motor.TransientRotation,
                            overlappedColliders: _probedColliders,
                            layers: Motor.CollidableLayers) > 0) {
                        // If obstructions, just stick to crouching dimensions
                        Motor.SetCapsuleDimensions(radius: 0.5, height: CrouchedCapsuleHeight, yOffset: CrouchedCapsuleHeight * 0.5)
                    } else {
                        // If no obstructions, uncrouch
                        MeshRoot!.scale = Vector3(1, 1, 1)
                        _isCrouching = false
                    }
                }
                break
            }
        }
    }

    public func IsColliderValidForCollisions(_ coll: Collider) -> Bool {
        if (IgnoredColliders.count == 0) {
            return true
        }

        if (IgnoredColliders.contains(coll)) {
            return false
        }

        return true
    }

    public func OnGroundHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3, hitStabilityReport: inout HitStabilityReport) {

    }

    public func OnMovementHit(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3, hitStabilityReport: inout HitStabilityReport) {

    }

    public func ProcessHitStabilityReport(hitCollider: Collider, hitNormal: Vector3, hitPoint: Vector3,
                                          atCharacterPosition: Vector3, atCharacterRotation: Quaternion,
                                          hitStabilityReport: inout HitStabilityReport) {

    }

    public func OnDiscreteCollisionDetected(hitCollider: Collider) {

    }


}
