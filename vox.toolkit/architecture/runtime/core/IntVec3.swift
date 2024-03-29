//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

/// Vertex positions are sorted as integers to avoid floating point precision errors.
struct IntVec3 {
    public var value = Vector3()

    public var x: Float {
        value.x
    }

    public var y: Float {
        value.y
    }

    public var z: Float {
        value.z
    }

    public init(vector: Vector3) {
        value = vector
    }

    public func Equals(_ p: IntVec3) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y) && round(z) == round(p.z)
    }

    public func Equals(_ p: Vector3) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y) && round(z) == round(p.z)
    }
}

extension IntVec3: Hashable {
    static func == (lhs: IntVec3, rhs: IntVec3) -> Bool {
        lhs.Equals(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(VectorHash.GetHashCode(value))
    }
}

extension IntVec3: CustomStringConvertible {
    var description: String {
        "({0:\(x)}, {1:\(y)}, {2:\(y)})"
    }
}
