//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

public class ExampleAIController: Script {
    public var MovementPeriod: Float = 1
    public var Characters: [ExampleCharacterController] = []

    public override func onUpdate(_ deltaTime: Float) {
        var inputs = AICharacterInputs()

        // Simulate an input on all controlled characters
        inputs.MoveVector = sin(engine.time.time * MovementPeriod) * Vector3.forward
        inputs.LookVector = Vector3.lerp(left: -Vector3.forward, right: Vector3.forward, t: inputs.MoveVector.z).normalized()
        for character in Characters {
            character.SetInputs(inputs)
        }
    }
}
