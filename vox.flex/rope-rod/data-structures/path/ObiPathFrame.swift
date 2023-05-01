//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public struct ObiPathFrame {
    public enum Axis: Int {
        case X = 0
        case Y = 1
        case Z = 2
    }

    public var position: Vector3

    public var tangent: Vector3
    public var normal: Vector3
    public var binormal: Vector3

    public var color: Vector4
    public var thickness: Float

    public init(position: Vector3, tangent: Vector3, normal: Vector3,
                binormal: Vector3, color: Vector4, thickness: Float)
    {
        self.position = position
        self.normal = normal
        self.tangent = tangent
        self.binormal = binormal
        self.color = color
        self.thickness = thickness
    }

    public func Reset() {}

    public static func + (c1: ObiPathFrame, c2: ObiPathFrame) -> ObiPathFrame {
        return ObiPathFrame(position: c1.position + c2.position,
                            tangent: c1.tangent + c2.tangent,
                            normal: c1.normal + c2.normal,
                            binormal: c1.binormal + c2.binormal,
                            color: c1.color + c2.color,
                            thickness: c1.thickness + c2.thickness)
    }

    public static func * (f: Float, c: ObiPathFrame) -> ObiPathFrame {
        return ObiPathFrame(position: c.position * f,
                            tangent: c.tangent * f,
                            normal: c.normal * f,
                            binormal: c.binormal * f,
                            color: c.color * f,
                            thickness: c.thickness * f)
    }

    public static func WeightedSum(w1 _: Float, w2 _: Float, w3 _: Float,
                                   c1 _: inout ObiPathFrame, c2 _: inout ObiPathFrame, c3 _: inout ObiPathFrame,
                                   sum _: inout ObiPathFrame) {}

    public func SetTwist(twist _: Float) {}

    public func SetTwistAndTangent(twist _: Float, tangent _: Vector3) {}

    public func Transport(frame _: ObiPathFrame, twist _: Float) {}

    public func Transport(newPosition _: Vector3, newTangent _: Vector3, twist _: Float) {}

    public func Transport(newPosition _: Vector3, newTangent _: Vector3, newNormal _: Vector3, twist _: Float) {}

    public func ToMatrix(mainAxis _: Axis) -> Matrix {
        Matrix()
    }
}
