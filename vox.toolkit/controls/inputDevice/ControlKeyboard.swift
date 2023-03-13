//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class ControlKeyboard : IControlInput {
    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType)->Void) {
        if (input.isKeyHeldDown(.VKEY_LEFT) ||
            input.isKeyHeldDown(.VKEY_RIGHT) ||
            input.isKeyHeldDown(.VKEY_UP) ||
            input.isKeyHeldDown(.VKEY_DOWN)) {
            callback(ControlHandlerType.PAN)
        } else {
            callback(ControlHandlerType.None)
        }
    }
    
    static func onUpdateDelta(_ control: OrbitControl, _ outDelta: inout Vector3) {
        var outDeltaVec = SIMD3<Float>(0, 0, outDelta.z)
        if (control.input.isKeyHeldDown(.VKEY_LEFT)) {
            outDeltaVec.x += control.keyPanSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_RIGHT)) {
            outDeltaVec.x -= control.keyPanSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_UP)) {
            outDeltaVec.y += control.keyPanSpeed
        }
        if (control.input.isKeyHeldDown(.VKEY_DOWN)) {
            outDeltaVec.y -= control.keyPanSpeed
        }
        outDelta = Vector3(outDeltaVec)
    }
}
