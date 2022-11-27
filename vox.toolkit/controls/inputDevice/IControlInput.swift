//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import vox_render

protocol IControlInput {
    static func onUpdateHandler(_ input: InputManager) -> ControlHandlerType
    static func onUpdateDelta(_ control: OrbitControl, outDelta: inout Vector3)
}
