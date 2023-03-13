//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

class ControlWheel : IControlInput {
    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType)->Void) {
        if (input.wheelDelta.x == 0 && input.wheelDelta.y == 0 && input.wheelDelta.z == 0) {
            callback(ControlHandlerType.None)
        } else {
            callback(ControlHandlerType.ZOOM)
        }
    }
    
    static func onUpdateDelta(_ control: OrbitControl, _ outDelta: inout Vector3) {
        outDelta = control.input.wheelDelta
    }
}
