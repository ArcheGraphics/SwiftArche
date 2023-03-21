//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Spot light.
public class SpotLight: Light {
    private static let _directLightProperty = "u_directLight"
    private static var _combinedData: [SpotLightData] = [SpotLightData](repeating: SpotLightData(), count: Light._maxLight)

    static func _updateShaderData(_ shaderData: ShaderData) {
        shaderData.setData(SpotLight._directLightProperty, SpotLight._combinedData)
    }

    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    public var distance: Float = 100
    /// Angle, in radians, from centre of spotlight where falloff begins.
    public var angle: Float = Float.pi / 6
    /// Angle, in radians, from falloff begins to ends.
    public var penumbra: Float = Float.pi / 12

    /// Get light direction.
    public var direction: Vector3 {
        get {
            entity.transform.worldForward
        }
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
        SpotLight._combinedData[lightIndex].color = _getLightColor()
        SpotLight._combinedData[lightIndex].position = entity.transform.worldPosition.internalValue
        SpotLight._combinedData[lightIndex].direction = direction.internalValue
        SpotLight._combinedData[lightIndex].distance = distance
        SpotLight._combinedData[lightIndex].angleCos = cos(angle)
        SpotLight._combinedData[lightIndex].penumbraCos = cos(angle + penumbra)
    }

    override func _onEnable() {
        Engine._lightManager._attachSpotLight(self)
    }

    override func _onDisable() {
        Engine._lightManager._detachSpotLight(self)
    }
    
    public required init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
