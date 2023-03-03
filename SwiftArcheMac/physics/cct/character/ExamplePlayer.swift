//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class ExamplePlayer: Script {
    public var Character: ExampleCharacterController?
    public var CharacterCamera: ExampleCharacterCamera?

    public override func onUpdate(_ deltaTime: Float) {
        HandleCharacterInput()
    }

    public override func onLateUpdate(_ deltaTime: Float) {
        if let CharacterCamera = CharacterCamera,
           let Character = Character,
           let Motor = Character.Motor {
            // Handle rotating the camera along with physics movers
            if (CharacterCamera.RotateWithPhysicsMover && Motor.AttachedRigidbody != nil) {
                let mover = Motor.AttachedRigidbody!.entity.getComponent(PhysicsMover.self)
                CharacterCamera.PlanarDirection = Vector3.transformByQuat(v: CharacterCamera.PlanarDirection,
                        quaternion: mover!.RotationDeltaFromInterpolation)
                CharacterCamera.PlanarDirection = Vector3.projectOnPlane(vector: CharacterCamera.PlanarDirection,
                        planeNormal: Motor.CharacterUp).normalized()
            }

            HandleCameraInput()
        }
    }

    private func HandleCameraInput() {
    }

    private func HandleCharacterInput() {
    }
}
