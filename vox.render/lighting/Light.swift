//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Light base class.
public class Light: Component {
    /// Each type of light source is at most 10, beyond which it will not take effect.
    static var _maxLight: Int = 10

    /// Light Intensity
    public var intensity: Float = 1
    /// How this light casts shadows.
    public var shadowType: ShadowType = ShadowType.None
    /// Shadow bias.
    public var shadowBias: Float = 1
    /// Shadow mapping normal-based bias.
    public var shadowNormalBias: Float = 1
    /// Near plane value to use for shadow frustums.
    public var shadowNearPlane: Float = 0.1
    /// Shadow intensity, the larger the value, the clearer and darker the shadow.
    public var shadowStrength: Float = 1.0
    // Light Color.
    public var color: Color = Color(1, 1, 1, 1)

    var _lightIndex: Int = -1

    /// View matrix.
    public var viewMatrix: Matrix {
        get {
            Matrix.invert(a: entity.transform.worldMatrix)
        }
    }

    /// Inverse view matrix.
    public var inverseViewMatrix: Matrix {
        get {
            entity.transform.worldMatrix
        }
    }

    func _getShadowProjectionMatrix() -> Matrix {
        Matrix()
    }

    func _getLightColor() -> SIMD3<Float> {
        let c = color * intensity
        return c.toLinear().rgb
    }
}
