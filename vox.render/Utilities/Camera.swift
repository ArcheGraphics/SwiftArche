//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import CoreGraphics

public struct Camera {
    var nearPlane: Float
    var farPlane: Float
    var fieldOfView: Float
    var projectionMatrix = simd_float4x4()

    public mutating func updateProjection(drawableSize: CGSize) {
        let fovyRadians = fieldOfView * Float.pi / 180
        let aspectRatio = Float(drawableSize.width) / Float(drawableSize.height)
        projectionMatrix = Transform.perspectiveProjection(fovyRadians, aspectRatio, nearPlane, farPlane)
    }
}
