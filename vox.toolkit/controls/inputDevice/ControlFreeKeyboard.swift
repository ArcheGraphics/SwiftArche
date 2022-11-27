//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render

class ControlFreeKeyboard : IControlInput {
    static func onUpdateHandler(_ input: InputManager)->ControlHandlerType {
        if (input.isKeyHeldDown(.VKEY_LEFT) ||
            input.isKeyHeldDown(.VKEY_A) ||
            input.isKeyHeldDown(.VKEY_UP) ||
            input.isKeyHeldDown(.VKEY_W) ||
            input.isKeyHeldDown(.VKEY_DOWN) ||
            input.isKeyHeldDown(.VKEY_S) ||
            input.isKeyHeldDown(.VKEY_RIGHT) ||
            input.isKeyHeldDown(.VKEY_D)) {
            return ControlHandlerType.PAN
        } else {
            return ControlHandlerType.None
        }
    }
    
    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3) {
        var outDeltaVec = SIMD3<Float>(repeating: 0)
        if (control.input.isKeyHeldDown(.VKEY_LEFT) || control.input.isKeyHeldDown(.VKEY_A)) {
            outDeltaVec.x -= control.movementSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_RIGHT) || control.input.isKeyHeldDown(.VKEY_D)) {
            outDeltaVec.x += control.movementSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_UP) || control.input.isKeyHeldDown(.VKEY_W)) {
            outDeltaVec.z -= control.movementSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_DOWN) || control.input.isKeyHeldDown(.VKEY_S)) {
            outDeltaVec.z += control.movementSpeed
        }
        outDelta = Vector3(outDeltaVec)
    }
}
