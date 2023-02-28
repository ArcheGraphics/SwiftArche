//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// The system that manages the simulation of KinematicCharacterMotor and PhysicsMover
public class KinematicCharacterSystem: Script {
    private static var _instance: KinematicCharacterSystem!

    public var CharacterMotors: [KinematicCharacterMotor] = []
    public var PhysicsMovers: [PhysicsMover] = []

    private var _lastCustomInterpolationStartTime: Float = -1
    private var _lastCustomInterpolationDeltaTime: Float = -1

    public var Settings = KCCSettings()

    /// Gets the KinematicCharacterSystem instance if any
    public static var instance: KinematicCharacterSystem {
        _instance
    }

    /// Sets the maximum capacity of the character motors list, to prevent allocations when adding characters
    public func SetCharacterMotorsCapacity(_ capacity: Int) {
        var capacity = capacity
        if (capacity < CharacterMotors.count) {
            capacity = CharacterMotors.count
        }
        CharacterMotors.reserveCapacity(capacity)
    }

    /// Registers a KinematicCharacterMotor into the system
    public func RegisterCharacterMotor(_ motor: KinematicCharacterMotor) {
        CharacterMotors.append(motor)
    }

    /// Unregisters a KinematicCharacterMotor from the system
    public func UnregisterCharacterMotor(_ motor: KinematicCharacterMotor) {
        CharacterMotors.removeAll() { v in
            v === motor
        }
    }

    /// Sets the maximum capacity of the physics movers list, to prevent allocations when adding movers
    public func SetPhysicsMoversCapacity(_ capacity: Int) {
        var capacity = capacity
        if (capacity < PhysicsMovers.count) {
            capacity = PhysicsMovers.count
        }
        PhysicsMovers.reserveCapacity(capacity)
    }

    /// Registers a PhysicsMover into the system
    public func RegisterPhysicsMover(_ mover: PhysicsMover) {
        PhysicsMovers.append(mover)
    }

    /// Unregisters a PhysicsMover from the system
    public func UnregisterPhysicsMover(_ mover: PhysicsMover) {
        PhysicsMovers.removeAll() { v in
            v === mover
        }
    }

    public required init(_ entity: Entity) {
        super.init(entity)
    }

    public override func onAwake() {
        KinematicCharacterSystem._instance = self
    }

    public override func onDisable() {
        KinematicCharacterSystem._instance = nil
    }

    public override func onPhysicsUpdate() {
        if (Settings.AutoSimulation) {
            let deltaTime = engine.time.deltaTime

            if (Settings.Interpolate) {
                PreSimulationInterpolationUpdate(deltaTime: deltaTime)
            }

            Simulate(deltaTime: deltaTime, motors: CharacterMotors, movers: PhysicsMovers)

            if (Settings.Interpolate) {
                PostSimulationInterpolationUpdate(deltaTime: deltaTime)
            }
        }
    }

    public override func onLateUpdate(_ deltaTime: Float) {
        if (Settings.Interpolate) {
            CustomInterpolationUpdate()
        }
    }

    /// Remembers the point to interpolate from for KinematicCharacterMotors and PhysicsMovers
    public func PreSimulationInterpolationUpdate(deltaTime: Float) {
        // Save pre-simulation poses and place transform at transient pose
        for motor in CharacterMotors {
            motor.InitialTickPosition = motor.TransientPosition
            motor.InitialTickRotation = motor.TransientRotation

            motor.Transform?.position = motor.TransientPosition
            motor.Transform?.rotationQuaternion = motor.TransientRotation
        }

        for mover in PhysicsMovers {
            mover.InitialTickPosition = mover.TransientPosition
            mover.InitialTickRotation = mover.TransientRotation

            mover.Transform?.position = mover.TransientPosition
            mover.Transform?.rotationQuaternion = mover.TransientRotation
        }
    }

    /// Ticks characters and/or movers
    public func Simulate(deltaTime: Float, motors: [KinematicCharacterMotor], movers: [PhysicsMover]) {
        let characterMotorsCount = motors.count
        let physicsMoversCount = movers.count

        // Update PhysicsMover velocities
        for i in 0..<physicsMoversCount {
            movers[i].VelocityUpdate(deltaTime: deltaTime)
        }

        // Character controller update phase 1
        for i in 0..<characterMotorsCount {
            // motors[i].UpdatePhase1(deltaTime)
        }

        // Simulate PhysicsMover displacement
        for i in 0..<physicsMoversCount {
            let mover = movers[i]

            mover.Transform?.position = mover.TransientPosition
            mover.Transform?.rotationQuaternion = mover.TransientRotation
        }

        // Character controller update phase 2 and move
        for i in 0..<characterMotorsCount {
            let motor = motors[i]

            // motor.UpdatePhase2(deltaTime)

            motor.Transform?.position = motor.TransientPosition
            motor.Transform?.rotationQuaternion = motor.TransientRotation
        }
    }

    /// Initiates the interpolation for KinematicCharacterMotors and PhysicsMovers
    public func PostSimulationInterpolationUpdate(deltaTime: Float) {
        _lastCustomInterpolationStartTime = engine.time.time
        _lastCustomInterpolationDeltaTime = deltaTime

        // Return interpolated roots to their initial poses
        for motor in CharacterMotors {
            motor.Transform?.position = motor.InitialTickPosition
            motor.Transform?.rotationQuaternion = motor.InitialTickRotation
        }

        for mover in PhysicsMovers {
            if (mover.MoveWithPhysics) {
                mover.Transform?.position = mover.InitialTickPosition
                mover.Transform?.rotationQuaternion = mover.InitialTickRotation

                mover.Rigidbody?.movePosition(mover.TransientPosition)
                mover.Rigidbody?.moveRotation(mover.TransientRotation)
            } else {
                mover.Transform?.position = mover.TransientPosition
                mover.Transform?.rotationQuaternion = mover.TransientRotation
            }
        }
    }

    /// Handles per-frame interpolation
    private func CustomInterpolationUpdate() {
        let interpolationFactor = simd_clamp((engine.time.time - _lastCustomInterpolationStartTime) /
                _lastCustomInterpolationDeltaTime, 0, 1)

        // Handle characters interpolation
        for motor in CharacterMotors {
            motor.Transform?.position = Vector3.lerp(left: motor.InitialTickPosition,
                    right: motor.TransientPosition, t: interpolationFactor)
            motor.Transform?.rotationQuaternion = Quaternion.slerp(start: motor.InitialTickRotation,
                    end: motor.TransientRotation, t: interpolationFactor)
        }

        // Handle PhysicsMovers interpolation
        for mover in PhysicsMovers {
            mover.Transform?.position = Vector3.lerp(left: mover.InitialTickPosition,
                    right: mover.TransientPosition, t: interpolationFactor)
            mover.Transform?.rotationQuaternion = Quaternion.slerp(start: mover.InitialTickRotation,
                    end: mover.TransientRotation, t: interpolationFactor)

            let newPos = mover.Transform?.position ?? Vector3()
            let newRot = mover.Transform?.rotationQuaternion ?? Quaternion()
            mover.PositionDeltaFromInterpolation = newPos - mover.LatestInterpolationPosition
            mover.RotationDeltaFromInterpolation = Quaternion.invert(a: mover.LatestInterpolationRotation) * newRot
            mover.LatestInterpolationPosition = newPos
            mover.LatestInterpolationRotation = newRot
        }
    }
}
