//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// The results of a raycast hit.
final class RaycastHit {
    public var distance: Float
    public var point: Vector3
    public var normal: Vector3
    public var face: Int

    public init(distance: Float,
                point: Vector3,
                normal: Vector3,
                face: Int)
    {
        self.distance = distance
        self.point = point
        self.normal = normal
        self.face = face
    }
}
