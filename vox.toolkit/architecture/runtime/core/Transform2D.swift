//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// A Transform class limited to 2D
final class Transform2D {
    /// Position in 2D space.
    public var position: Vector2

    /// Rotation in degrees.
    public var rotation: Float

    /// Scale in 2D space.
    public var scale: Vector2

    public init(position: Vector2, rotation: Float, scale: Vector2) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    public func TransformPoint(_ p: Vector2) -> Vector2 {
        Vector2()
    }
}

extension Transform2D: CustomStringConvertible {
    var description: String {
        ""
    }
}
