//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class ShadowSliceData {
    var resolution: UInt32 = 0
    var virtualCamera: CameraInfo = CameraInfo()
    var cullPlanes: [Plane] = [
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3()),
        Plane(Vector3())
    ]
    var cullPlaneCount: Int = 0

    // bounding sphere
    var splitBoundSphere: BoundingSphere = BoundingSphere(Vector3(), 0.0)
    var sphereCenterZ: Float = 0
}
