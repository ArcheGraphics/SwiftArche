//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// A class for storing and applying Vector2 masks.
final class HandleConstraint2D {
    public var x: Int, y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func Inverse() -> HandleConstraint2D {
        HandleConstraint2D(x: x == 1 ? 0 : 1, y: y == 1 ? 0 : 1)
    }

    public func Mask(_ v: Vector2) -> Vector2 {
        var v = v
        v.x *= Float(x)
        v.y *= Float(y)
        return v
    }

    public func InverseMask(_ v: Vector2) -> Vector2 {
        var v = v
        v.x *= x == 1 ? 0 : 1
        v.y *= y == 1 ? 0 : 1
        return v
    }

    public static let None = HandleConstraint2D(x: 1, y: 1)
}

extension HandleConstraint2D: Hashable {
    static func ==(a: HandleConstraint2D, b: HandleConstraint2D) -> Bool {
        a.x == b.x && a.y == b.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension HandleConstraint2D: CustomStringConvertible {
    var description: String {
        "(\(x), \(y)"
    }
}
