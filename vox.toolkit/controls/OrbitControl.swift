//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render

public class OrbitControl : Script {
    let input: InputManager;
//    let inputDevices: [IControlInput] = [ControlPointer];
    var camera: Camera!
    var cameraTransform: Transform!
    
    public required init(_ entity: Entity) {
        input = entity.engine.inputManager
        super.init(entity)
    }
}
