//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Point light.
public class PointLight: Light {
    private static let _pointLightProperty = "u_pointLight"
    private static var _combinedData: [PointLightData] = .init(repeating: PointLightData(), count: Light._maxLight)

    static func _updateShaderData(_ shaderData: ShaderData) {
        shaderData.setData(with: PointLight._pointLightProperty, array: PointLight._combinedData)
    }

    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    @Serialized(default: 100)
    public var distance: Float

    func _appendData(_ lightIndex: Int) {
        PointLight._combinedData[lightIndex].color = _getLightColor()
        PointLight._combinedData[lightIndex].posSqrRadius = SIMD4<Float>(entity.transform.worldPosition.internalValue,
                                                                         distance * distance)
    }

    override func _onEnable() {
        Engine._lightManager._attachPointLight(self)
    }

    override func _onDisable() {
        Engine._lightManager._detachPointLight(self)
    }
}
