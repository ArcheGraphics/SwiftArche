//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

enum StepGenerationType {
    case Height
    case Count
}

public class Stairs: Shape {
    var m_StepGenerationType = StepGenerationType.Count

    var m_StepsHeight: Float = 0.2

    var m_StepsCount = 10

    var m_HomogeneousSteps = true

    var m_Circumference: Float = 0

    var m_Sides = true

    public var sides: Bool {
        get {
            m_Sides
        }
        set {
            m_Sides = newValue
        }
    }

    public func CopyShape(_ shape: Shape) {

    }

    public func UpdateBounds(mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion, bounds: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }

    func BuildStairs(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }

    func BuildCurvedStairs(_ mesh: ProBuilderMesh, size: Vector3, rotation: Quaternion) -> Bounds {
        Bounds()
    }

}
