//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Light base class.
public class Light: Component {
    /// Each type of light source is at most 10, beyond which it will not take effect.
    static var _maxLight: Int = 10

    /// Culling mask - which layers the light affect.
    /// - Remark: Support bit manipulation, corresponding to `Layer`.
    @Serialized(default: Layer.Everything)
    public var cullingMask: Layer
    
    /// Light Intensity
    @Serialized(default: 1)
    public var intensity: Float
    
    /// How this light casts shadows.
    @Serialized(default: ShadowType.None)
    public var shadowType: ShadowType
    
    /// Shadow bias.
    @Serialized(default: 1)
    public var shadowBias: Float
    
    /// Shadow mapping normal-based bias.
    @Serialized(default: 1)
    public var shadowNormalBias: Float
    
    /// Near plane value to use for shadow frustums.
    @Serialized(default: 0.1)
    public var shadowNearPlane: Float

    /// Shadow intensity, the larger the value, the clearer and darker the shadow.
    @Serialized(default: 1.0)
    public var shadowStrength: Float
    
    // Light Color.
    @Serialized(default: Color(1, 1, 1, 1))
    public var color: Color

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
