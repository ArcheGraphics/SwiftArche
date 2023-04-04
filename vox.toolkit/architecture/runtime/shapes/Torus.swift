//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public class Torus: Shape {
    var m_Rows = 16

    var m_Columns = 24

    var m_TubeRadius: Float = 0.1

    var m_HorizontalCircumference: Float = 360

    var m_VerticalCircumference: Float = 360

    var m_Smooth = true

    public func CopyShape(_: Shape) {}

    public func UpdateBounds(mesh _: ProBuilderMesh, size _: Vector3, rotation _: Quaternion, bounds _: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }

    static func GetCirclePoints(segments _: Int, radius _: Float, circumference _: Float, rotation _: Quaternion, offset _: Float) -> [Vector3] {
        []
    }

    static func GetCirclePoints(segments _: Int, radius _: Float, circumference _: Float, rotation _: Quaternion, offset _: Vector3) -> [Vector3] {
        []
    }
}
