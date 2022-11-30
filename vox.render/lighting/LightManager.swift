//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// Light manager.
class LightManager {
    var _spotLights: DisorderedArray<SpotLight> = DisorderedArray()
    var _pointLights: DisorderedArray<PointLight> = DisorderedArray()
    var _directLights: DisorderedArray<DirectLight> = DisorderedArray()

    func _attachSpotLight(_ light: SpotLight) {
        light._lightIndex = _spotLights.count
        _spotLights.add(light)
    }

    func _detachSpotLight(_ light: SpotLight) {
        let replaced = _spotLights.deleteByIndex(light._lightIndex)
        if replaced != nil {
            replaced!._lightIndex = light._lightIndex
        }
        light._lightIndex = -1
    }


    func _attachPointLight(_ light: PointLight) {
        light._lightIndex = _pointLights.count
        _pointLights.add(light)
    }


    func _detachPointLight(_ light: PointLight) {
        let replaced = _pointLights.deleteByIndex(light._lightIndex)
        if replaced != nil {
            replaced!._lightIndex = light._lightIndex
        }
        light._lightIndex = -1
    }


    func _attachDirectLight(_ light: DirectLight) {
        light._lightIndex = _directLights.count
        _directLights.add(light)
    }


    func _detachDirectLight(_ light: DirectLight) {
        let replaced = _directLights.deleteByIndex(light._lightIndex)
        if replaced != nil {
            replaced!._lightIndex = light._lightIndex
        }
        light._lightIndex = -1
    }

    func _getSunLightIndex() -> Int {
        var sunLightIndex = -1
        var maxIntensity = -Float.greatestFiniteMagnitude
        var hasShadowLight = false
        for i in 0..<_directLights.count {
            let directLight = _directLights.get(i)!
            if (directLight.shadowType != ShadowType.None && !hasShadowLight) {
                maxIntensity = -Float.greatestFiniteMagnitude
                hasShadowLight = true
            }
            let intensity = directLight.intensity * directLight.color.getBrightness()
            if (hasShadowLight) {
                if (directLight.shadowType != ShadowType.None && maxIntensity < intensity) {
                    maxIntensity = intensity
                    sunLightIndex = i
                }
            } else {
                if (maxIntensity < intensity) {
                    maxIntensity = intensity
                    sunLightIndex = i
                }
            }
        }
        return sunLightIndex
    }

    func _updateShaderData(_ shaderData: ShaderData) {
        let spotLightCount = _spotLights.count
        let pointLightCount = _pointLights.count
        let directLightCount = _directLights.count

        for i in 0..<spotLightCount {
            _spotLights.get(i)!._appendData(i)
        }

        for i in 0..<pointLightCount {
            _pointLights.get(i)!._appendData(i)
        }

        for i in 0..<directLightCount {
            _directLights.get(i)!._appendData(i)
        }

        if (directLightCount != 0) {
            DirectLight._updateShaderData(shaderData)
            shaderData.enableMacro(DIRECT_LIGHT_COUNT.rawValue, (directLightCount, .int))
        } else {
            shaderData.disableMacro(DIRECT_LIGHT_COUNT.rawValue)
        }

        if (pointLightCount != 0) {
            PointLight._updateShaderData(shaderData)
            shaderData.enableMacro(POINT_LIGHT_COUNT.rawValue, (pointLightCount, .int))
        } else {
            shaderData.disableMacro(POINT_LIGHT_COUNT.rawValue)
        }

        if (spotLightCount != 0) {
            SpotLight._updateShaderData(shaderData)
            shaderData.enableMacro(SPOT_LIGHT_COUNT.rawValue, (spotLightCount, .int))
        } else {
            shaderData.disableMacro(SPOT_LIGHT_COUNT.rawValue)
        }
    }
}
