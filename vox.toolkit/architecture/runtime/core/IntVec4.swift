//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Vertex positions are sorted as integers to avoid floating point precision errors.
struct IntVec4 {
    public var value = Vector4()

    public var x: Float {
        value.x
    }

    public var y: Float {
        value.y
    }

    public var z: Float {
        value.z
    }

    public var w: Float {
        value.w
    }

    public init(vector: Vector4) {
        value = vector
    }

    public func Equals(_ p: IntVec4) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y) && round(z) == round(p.z) && round(w) == round(p.w)
    }

    public func Equals(_ p: Vector4) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y) && round(z) == round(p.z) && round(w) == round(p.w)
    }
}

extension IntVec4: Hashable {
    static func == (lhs: IntVec4, rhs: IntVec4) -> Bool {
        lhs.Equals(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(VectorHash.GetHashCode(value))
    }
}

extension IntVec4: CustomStringConvertible {
    var description: String {
        "({0:\(x)}, {1:\(y)}, {2:\(y)}, {3:\(y)})"
    }
}
