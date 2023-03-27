//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

// Stores a list of keypoints.
//  Supports attaching to a camera, then updates to the controller time with
//  `updateTimeInSeconds` updates the camera transform.
//  Keypoints can be added and removed and serialized to/from file.
class XCameraController {
    init() {}
    
    // Runtime usage - attach, update or move to a new keypoint.
    func attach(to camera: XCamera) {}
    
    func updateTime(in seconds: CFAbsoluteTime) {}
    
    func moveTo(index: Int) {}
}
