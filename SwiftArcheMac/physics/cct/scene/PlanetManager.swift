//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class PlanetManager: Script {
    public var PlanetMover: PhysicsMover?
    public var GravityStrength: Float = 10
    public var OrbitAxis = Vector3.forward
    public var OrbitSpeed: Float = 10

    public var OnPlaygroundTeleportingZone: Teleporter!
    public var OnPlanetTeleportingZone: Teleporter!

    private var _characterControllersOnPlanet: [ExampleCharacterController] = []
    private var _savedGravity = Vector3()
    private var _lastRotation = Quaternion()

    public override func onStart() {
        if let PlanetMover = PlanetMover {
            // OnPlaygroundTeleportingZone.OnCharacterTeleport -= ControlGravity
            // OnPlaygroundTeleportingZone.OnCharacterTeleport += ControlGravity

            // OnPlanetTeleportingZone.OnCharacterTeleport -= UnControlGravity
            // OnPlanetTeleportingZone.OnCharacterTeleport += UnControlGravity

            _lastRotation = PlanetMover.entity.transform.rotationQuaternion

            PlanetMover.MoverController = self
        }
    }

    func ControlGravity(cc: ExampleCharacterController) {
        _savedGravity = cc.Gravity
        _characterControllersOnPlanet.append(cc)
    }

    func UnControlGravity(cc: ExampleCharacterController) {
        cc.Gravity = _savedGravity
        _characterControllersOnPlanet.removeAll(where: { v in
            v === cc
        })
    }
}

extension PlanetManager: IMoverController {
    public func UpdateMovement(goalPosition: inout Vector3, goalRotation: inout Quaternion, deltaTime: Float) {
        if let PlanetMover = PlanetMover,
           let Rigidbody = PlanetMover.Rigidbody {
            goalPosition = Rigidbody.entity.transform.position

            // Rotate
            let targetRotation = Quaternion.euler(OrbitAxis * OrbitSpeed * deltaTime) * _lastRotation
            goalRotation = targetRotation
            _lastRotation = targetRotation

            // Apply gravity to characters
            for cc in _characterControllersOnPlanet {
                cc.Gravity = (PlanetMover.entity.transform.position - cc.entity.transform.position).normalized() * GravityStrength
            }
        }
    }
}
