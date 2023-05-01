//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ObiWingedPoint {
    public enum TangentMode {
        case Aligned
        case Mirrored
        case Free
    }

    public var tangentMode: TangentMode
    public var inTangent: Vector3
    public var position: Vector3
    public var outTangent: Vector3

    public var inTangentEndpoint: Vector3 { return position + inTangent }

    public var outTangentEndpoint: Vector3 { return position + outTangent }

    public init(inTangent: Vector3, point: Vector3, outTangent: Vector3) {
        tangentMode = TangentMode.Aligned
        self.inTangent = inTangent
        position = point
        self.outTangent = outTangent
    }

    public func SetInTangentEndpoint(value _: Vector3) {}

    public func SetOutTangentEndpoint(value _: Vector3) {}

    public func SetInTangent(value _: Vector3) {}

    public func SetOutTangent(value _: Vector3) {}

    public func Transform(translation _: Vector3, rotation _: Quaternion, scale _: Vector3) {}
}
