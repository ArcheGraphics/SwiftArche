//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

/// Point light.
public class PointLight: Light {
    struct LightData {
        var color = Vector3()
        var position = Vector3()
        var distance: Float = 0
    }

    private static let _pointLightProperty = "u_pointLight"
    private static var _combinedData: [LightData] = [LightData](repeating: LightData(), count: Light._maxLight)

    static func _updateShaderData(_ shaderData: ShaderData) {
        shaderData.setData(PointLight._pointLightProperty, PointLight._combinedData);
    }

    /// Defines a distance cutoff at which the light's intensity must be considered zero.
    public var distance: Float = 100

    func _appendData(_ lightIndex: Int) {
        PointLight._combinedData[lightIndex].color = _getLightColor()
        PointLight._combinedData[lightIndex].position = entity.transform.worldPosition
        PointLight._combinedData[lightIndex].distance = distance
    }

    override func _onEnable() {
        engine._lightManager._attachPointLight(self)
    }

    override func _onDisable() {
        engine._lightManager._detachPointLight(self)
    }
}
