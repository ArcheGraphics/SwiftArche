//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Represents the entire state of a PhysicsMover that is pertinent for simulation.
/// Use this to save state or revert to past state
public struct PhysicsMoverState {
    public var Position = Vector3()
    public var Rotation = Quaternion()
    public var Velocity = Vector3()
    public var AngularVelocity = Vector3()
}

/// Component that manages the movement of moving kinematic rigidbodies for
/// proper interaction with characters
public class PhysicsMover: Script {
    /// The mover's Rigidbody
    public var Rigidbody: DynamicCollider?

    /// Determines if the platform moves with rigidbody.MovePosition (when true), or with rigidbody.position (when false)
    public var MoveWithPhysics = true

    /// Index of this motor in KinematicCharacterSystem arrays
    public var MoverController: IMoverController?
    /// Remembers latest position in interpolation
    public var LatestInterpolationPosition = Vector3()
    /// Remembers latest rotation in interpolation
    public var LatestInterpolationRotation = Quaternion()
    /// The latest movement made by interpolation
    public var PositionDeltaFromInterpolation = Vector3()
    /// The latest rotation made by interpolation
    public var RotationDeltaFromInterpolation = Quaternion()

    //MARK: - Override
    /// Index of this motor in KinematicCharacterSystem arrays
    public var IndexInCharacterSystem: Int {
        get {
            0
        }
        set {
        }
    }
    /// Remembers initial position before all simulation are done
    public var Velocity: Vector3 {
        get {
            Vector3()
        }
        set {
        }
    }
    /// Remembers initial position before all simulation are done
    public var AngularVelocity: Vector3 {
        get {
            Vector3()
        }
        set {
        }
    }
    /// Remembers initial position before all simulation are done
    public var InitialTickPosition: Vector3 {
        get {
            Vector3()
        }
        set {
        }
    }
    /// Remembers initial rotation before all simulation are done
    public var InitialTickRotation: Quaternion {
        get {
            Quaternion()
        }
        set {
        }
    }

    /// The mover's Transform
    public var Transform: Transform! {
        get {
            nil
        }
        set {
        }
    }
    /// The character's position before the movement calculations began
    public var InitialSimulationPosition: Vector3 {
        get {
            Vector3()
        }
        set {
        }
    }
    /// The character's rotation before the movement calculations began
    public var InitialSimulationRotation: Quaternion {
        get {
            Quaternion()
        }
        set {
        }
    }

    /// The mover's rotation (always up-to-date during the character update phase)
    public var TransientPosition: Vector3 {
        get {
            _internalTransientPosition
        }
        set {
            _internalTransientPosition = newValue
        }
    }
    private var _internalTransientPosition = Vector3()

    /// The mover's rotation (always up-to-date during the character update phase)
    public var TransientRotation: Quaternion {
        get {
            _internalTransientRotation
        }
        set {
            _internalTransientRotation = newValue
        }
    }
    private var _internalTransientRotation = Quaternion()

    /// Handle validating all required values
    public func ValidateData() {
        Rigidbody = entity.getComponent()
        if let Rigidbody = Rigidbody {
            Rigidbody.centerOfMass = Vector3.zero
            Rigidbody.maxAngularVelocity = Float.infinity
            Rigidbody.maxDepenetrationVelocity = Float.infinity
            Rigidbody.isKinematic = true
        }
    }
    
    public override func onEnable() {
        KinematicCharacterSystem.instance.RegisterPhysicsMover(self)
    }
    
    public override func onDisable() {
        KinematicCharacterSystem.instance.UnregisterPhysicsMover(self)
    }

    public override func onAwake() {
        Transform = entity.transform
        ValidateData()

        if let Transform = Transform {
            TransientPosition = Transform.position
            TransientRotation = Transform.rotationQuaternion
            InitialSimulationPosition = Transform.position
            InitialSimulationRotation = Transform.rotationQuaternion
            LatestInterpolationPosition = Transform.position
            LatestInterpolationRotation = Transform.rotationQuaternion
        }
    }

    /// Sets the mover's position directly
    public func SetPosition(_ position: Vector3) {
        Transform?.position = position
        InitialSimulationPosition = position
        TransientPosition = position
    }

    /// Sets the mover's rotation directly
    public func SetRotation(_ rotation: Quaternion) {
        Transform?.rotationQuaternion = rotation
        InitialSimulationRotation = rotation
        TransientRotation = rotation
    }

    /// Sets the mover's position and rotation directly
    public func SetPositionAndRotation(_ position: Vector3, _ rotation: Quaternion) {
        Transform?.rotationQuaternion = rotation
        Transform?.position = position
        InitialSimulationPosition = position
        InitialSimulationRotation = rotation
        TransientPosition = position
        TransientRotation = rotation
    }

    /// Returns all the state information of the mover that is pertinent for simulation
    public func GetState() -> PhysicsMoverState {
        var state = PhysicsMoverState()

        state.Position = TransientPosition
        state.Rotation = TransientRotation
        state.Velocity = Velocity
        state.AngularVelocity = AngularVelocity

        return state
    }

    /// Applies a mover state instantly
    public func ApplyState(_ state: PhysicsMoverState) {
        SetPositionAndRotation(state.Position, state.Rotation)
        Velocity = state.Velocity
        AngularVelocity = state.AngularVelocity
    }

    /// Caches velocity values based on deltatime and target position/rotations
    public func VelocityUpdate(deltaTime: Float) {
        InitialSimulationPosition = TransientPosition
        InitialSimulationRotation = TransientRotation

        MoverController?.UpdateMovement(goalPosition: &_internalTransientPosition,
                goalRotation: &_internalTransientRotation, deltaTime: deltaTime)

        if (deltaTime > 0) {
            Velocity = (TransientPosition - InitialSimulationPosition) / deltaTime

            let rotationFromCurrentToGoal = TransientRotation * (Quaternion.invert(a: InitialSimulationRotation))
            AngularVelocity = (rotationFromCurrentToGoal.toEuler() * MathUtil.degreeToRadFactor) / deltaTime
        }
    }
}
