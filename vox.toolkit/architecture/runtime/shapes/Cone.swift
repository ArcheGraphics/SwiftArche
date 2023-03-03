//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class Cone: Shape {
    internal var m_NumberOfSides = 6

    var m_Radius: Float = 0

    var m_Smooth = true

    public func CopyShape(_ shape: Shape) {

    }

    public func UpdateBounds(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion, bounds: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }
}
