//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Spot light.
public class SpotLight: Light {
    private static let _spotLightProperty = "u_spotLight"
    private static var _combinedData: [SpotLightData] = .init(repeating: SpotLightData(), count: Light._maxLight)

    static func _updateShaderData(_ shaderData: ShaderData) {
        shaderData.setData(with: SpotLight._spotLightProperty, array: SpotLight._combinedData)
    }

    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    @Serialized(default: 100)
    public var distance: Float

    /// Angle, in radians, from centre of spotlight where falloff begins.
    @Serialized(default: Float.pi / 6)
    public var angle: Float

    /// Angle, in radians, from falloff begins to ends.
    @Serialized(default: Float.pi / 12)
    public var penumbra: Float

    /// Get light direction.
    public var direction: Vector3 {
        entity.transform.worldForward
    }

    /// Get the opposite direction of the spotlight.
    public var reverseDirection: Vector3 {
        direction * -1
    }

    override func _getShadowProjectionMatrix() -> Matrix {
        let fov = Swift.min(Float.pi / 2, angle * 2 * sqrt(2))
        return Matrix.perspective(fovy: fov, aspect: 1, near: shadowNearPlane, far: distance + shadowNearPlane)
    }

    internal func _appendData(_ lightIndex: Int) {
        SpotLight._combinedData[lightIndex].colorAndInnerAngle = SIMD4<Float>(_getLightColor(), cos(angle))
        SpotLight._combinedData[lightIndex].boundingSphere = SIMD4<Float>(entity.transform.worldPosition.internalValue, distance)
        SpotLight._combinedData[lightIndex].dirAndOuterAngle = SIMD4<Float>(direction.internalValue, cos(angle + penumbra))
        // TODO: Shader Culling
    }

    override func _onEnable() {
        Engine._lightManager._attachSpotLight(self)
    }

    override func _onDisable() {
        Engine._lightManager._detachSpotLight(self)
    }
}
