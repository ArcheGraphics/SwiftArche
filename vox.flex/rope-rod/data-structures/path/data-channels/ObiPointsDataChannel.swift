//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public class ObiPointsDataChannel: ObiPathDataChannel<ObiWingedPoint, ObiCatmullRomInterpolator3D> {
    public init() {
        super.init(interpolator: ObiCatmullRomInterpolator3D())
    }

    public func GetTangent(index _: Int) -> Vector3 {
        Vector3()
    }

    public func GetAcceleration(index _: Int) -> Vector3 {
        Vector3()
    }

    /// spline position at time mu, with 0<=mu<=1 where 0 is the start of the spline and 1 is the end.
    public func GetPositionAtMu(closed _: Bool, mu _: Float) -> Vector3 {
        Vector3()
    }

    /// normal tangent vector at time mu, with 0<=mu<=1 where 0 is the start of the spline and 1 is the end.
    public func GetTangentAtMu(closed _: Bool, mu _: Float) -> Vector3 {
        Vector3()
    }

    /// acceleration at time mu, with 0<=mu<=1 where 0 is the start of the spline and 1 is the end.
    public func GetAccelerationAtMu(closed _: Bool, mu _: Float) -> Vector3 {
        Vector3()
    }
}
