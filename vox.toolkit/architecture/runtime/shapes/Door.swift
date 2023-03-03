//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class Door: Shape {
    var m_DoorHeight: Float = 0.5

    var m_LegWidth: Float = 0.75

    public func CopyShape(_ shape: Shape) {

    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }
}
