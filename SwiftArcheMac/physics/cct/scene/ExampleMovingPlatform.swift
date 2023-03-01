//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class ExampleMovingPlatform: Script {
    public var Mover: PhysicsMover?

    public var TranslationAxis = Vector3.right
    public var TranslationPeriod: Float = 10
    public var TranslationSpeed: Float = 1
    public var RotationAxis = Vector3.up
    public var RotSpeed: Float = 10
    public var OscillationAxis = Vector3.zero
    public var OscillationPeriod: Float = 10
    public var OscillationSpeed: Float = 10

    private var _originalPosition = Vector3()
    private var _originalRotation = Quaternion()

    public override func onStart() {
        if let Mover = Mover,
           let Rigidbody = Mover.Rigidbody {
            _originalPosition = Rigidbody.entity.transform.position
            _originalRotation = Rigidbody.entity.transform.rotationQuaternion

            Mover.MoverController = self
        }
    }
}

extension ExampleMovingPlatform: IMoverController {
    public func UpdateMovement(goalPosition: inout Vector3, goalRotation: inout Quaternion, deltaTime: Float) {
        let time = engine.time.time
        goalPosition = (_originalPosition + (TranslationAxis.normalized() * sin(time * TranslationSpeed) * TranslationPeriod))

        let targetRotForOscillation = Quaternion.euler(OscillationAxis.normalized() * (sin(time * OscillationSpeed) * OscillationPeriod)) * _originalRotation
        goalRotation = Quaternion.euler(RotationAxis * RotSpeed * time) * targetRotForOscillation
    }
}
