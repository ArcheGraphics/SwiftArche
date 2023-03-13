//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

public class Torus: Shape {
    var m_Rows = 16

    var m_Columns = 24

    var m_TubeRadius: Float = 0.1

    var m_HorizontalCircumference: Float = 360

    var m_VerticalCircumference: Float = 360

    var m_Smooth = true

    public func CopyShape(_ shape: Shape) {

    }

    public func UpdateBounds(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion, bounds: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }

    static func GetCirclePoints(segments: Int, radius: Float, circumference: Float, rotation: Quaternion, offset: Float) -> [Vector3] {
        []
    }

    static func GetCirclePoints(segments: Int, radius: Float, circumference: Float, rotation: Quaternion, offset: Vector3) -> [Vector3] {
        []
    }
}
