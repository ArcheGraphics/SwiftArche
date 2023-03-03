//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class Arch: Shape {
    var m_Thickness: Float = 0.1

    var m_NumberOfSides: Int = 5

    var m_ArchDegrees: Float = 180

    var m_EndCaps = true

    var m_Smooth = true

    public func CopyShape(_ shape: Shape) {

    }

    func GetFace(vertex1: Vector2, vertex2: Vector2, depth: Float) -> [Vector3] {
        []
    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }
}
