//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class Plane: Shape {
    var m_HeightSegments = 1

    var m_WidthSegments = 1

    public func CopyShape(_: Shape) {}

    public func RebuildMesh(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }
}
