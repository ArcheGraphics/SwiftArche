//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render

protocol IControlInput {
    static func onUpdateHandler(_ input: InputManager, callback: (ControlHandlerType) -> Void)
    
    static func onUpdateDelta(_ control: OrbitControl, _ outDelta: inout Vector3)
    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3)
}

extension IControlInput {
    static func onUpdateDelta(_ control: OrbitControl, _ outDelta: inout Vector3) {}
    static func onUpdateDelta(_ control: FreeControl, _ outDelta: inout Vector3) {}
}
