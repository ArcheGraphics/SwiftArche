//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class Arch: Shape {
    var m_Thickness: Float = 0.1

    var m_NumberOfSides: Int = 5

    var m_ArchDegrees: Float = 180

    var m_EndCaps = true

    var m_Smooth = true

    public func CopyShape(_: Shape) {}

    func GetFace(vertex1 _: Vector2, vertex2 _: Vector2, depth _: Float) -> [Vector3] {
        []
    }

    public func RebuildMesh(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }
}
