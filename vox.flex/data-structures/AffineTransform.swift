//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import vox_render

public struct AffineTransform {
    public var translation: Vector4
    public var scale: Vector4
    public var rotation: Quaternion

    public init(translation: Vector4, rotation: Quaternion, scale: Vector4) {
        self.translation = translation
        self.rotation = rotation
        self.scale = scale

        // make sure there are good values in the 4th component:
        self.translation.w = 0
        self.scale.w = 1
    }

    public mutating func FromTransform(source: Transform, is2D: Bool = false) {
        translation = Vector4(source.worldPosition, 0)
        rotation = source.worldRotationQuaternion
        scale = Vector4(source.lossyWorldScale, 0)

        if is2D {
            translation.z = 0
        }
    }
}
