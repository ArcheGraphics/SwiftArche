//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// How bezier handles behave when being manipulated in the scene view.
enum BezierTangentMode {
    case Free
    case Aligned
    case Mirrored
}

enum BezierTangentDirection {
    case In
    case Out
}

/// A bezier knot.
struct BezierPoint {
    public var position: Vector3
    public var tangentIn: Vector3
    public var tangentOut: Vector3
    public var rotation: Quaternion

    public func EnforceTangentMode(master _: BezierTangentDirection, mode _: BezierTangentMode) {}

    /// Set the position while also moving tangent points.
    public func SetPosition(_: Vector3) {}

    public func SetTangentIn(_: Vector3, mode _: BezierTangentMode) {}

    public func SetTangentOut(_: Vector3, mode _: BezierTangentMode) {}

    public static func QuadraticPosition(a _: BezierPoint, b _: BezierPoint, t _: Float) -> Vector3 {
        Vector3()
    }

    public static func CubicPosition(a _: BezierPoint, b _: BezierPoint, t _: Float) -> Vector3 {
        Vector3()
    }

    public static func GetLookDirection(points _: [BezierPoint], index _: Int, previous _: Int, next _: Int) -> Vector3 {
        Vector3()
    }
}
