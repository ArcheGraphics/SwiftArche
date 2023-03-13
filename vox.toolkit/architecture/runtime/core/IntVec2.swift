//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Vertex positions are sorted as integers to avoid floating point precision errors.
struct IntVec2 {
    public var value = Vector2()

    public var x: Float {
        get {
            value.x
        }
    }
    public var y: Float {
        get {
            value.y
        }
    }

    public init(vector: Vector2) {
        value = vector
    }

    public func Equals(_ p: IntVec2) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y)
    }

    public func Equals(_ p: Vector2) -> Bool {
        round(x) == round(p.x) && round(y) == round(p.y)
    }
}

extension IntVec2: Hashable {
    static func ==(lhs: IntVec2, rhs: IntVec2) -> Bool {
        lhs.Equals(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(VectorHash.GetHashCode(value))
    }
}

extension IntVec2: CustomStringConvertible {
    var description: String {
        "({0:\(x)}, {1:\(y)})"
    }
}
