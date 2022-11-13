//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class CameraInfo {
    var position: Vector3 = Vector3();
    var viewMatrix: Matrix = Matrix();
    var projectionMatrix: Matrix = Matrix();
    var viewProjectionMatrix: Matrix = Matrix();

    var isOrthographic: Bool = false;
    /// Only orthography mode use.
    var forward: Vector3 = Vector3();
}
