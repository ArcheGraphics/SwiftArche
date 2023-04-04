//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class Pipe: Shape {
    var m_Thickness: Float = 0.25

    var m_NumberOfSides = 6

    var m_HeightCuts = 0

    var m_Smooth = true

    public func CopyShape(_: Shape) {}

    public func UpdateBounds(mesh _: ProBuilderMesh, size _: Vector3, rotation _: Quaternion, bounds _: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }
}
