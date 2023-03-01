//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math
import vox_toolkit

class MyPlayer: Script {
    public var OrbitCamera: ExampleCharacterCamera?
    public var CameraFollowPoint: Transform?
    public var Character: MyCharacterController?

    private var _lookInputVector = Vector3.zero;
    
    override func onStart() {
        if let OrbitCamera = OrbitCamera {
            // Tell camera to follow transform
            OrbitCamera.SetFollowTransform(CameraFollowPoint!);
            // Ignore the character's collider(s) for camera obstruction checks
            OrbitCamera.IgnoredColliders = Character!.entity.getComponentsIncludeChildren()
        }
    }
}
