//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

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

    public func CopyShape(_: Shape) {}

    public func UpdateBounds(mesh _: ProBuilderMesh, size _: Vector3, rotation _: Quaternion, bounds _: Bounds) -> Bounds {
        Bounds()
    }

    public func RebuildMesh(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }

    func BuildStairs(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }

    func BuildCurvedStairs(_: ProBuilderMesh, size _: Vector3, rotation _: Quaternion) -> Bounds {
        Bounds()
    }
}
