//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math


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

    public func EnforceTangentMode(master: BezierTangentDirection, mode: BezierTangentMode) {
    }


    /// Set the position while also moving tangent points.
    public func SetPosition(_ position: Vector3) {
    }

    public func SetTangentIn(_ tangent: Vector3, mode: BezierTangentMode) {

    }

    public func SetTangentOut(_ tangent: Vector3, mode: BezierTangentMode) {

    }

    public static func QuadraticPosition(a: BezierPoint, b: BezierPoint, t: Float) -> Vector3 {
        Vector3()
    }

    public static func CubicPosition(a: BezierPoint, b: BezierPoint, t: Float) -> Vector3 {
        Vector3()
    }

    public static func GetLookDirection(points: [BezierPoint], index: Int, previous: Int, next: Int) -> Vector3 {
        Vector3()
    }
}
