//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class CameraInfo {
    var position: Vector3 = .init()
    var viewMatrix: Matrix = .init()
    var projectionMatrix: Matrix = .init()
    var viewProjectionMatrix: Matrix = .init()

    var isOrthographic: Bool = false
    /// Only orthography mode use.
    var forward: Vector3 = .init()
}
