//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

struct XLightingEnvironment {
    var exposure: Float = 0
    var sunColor = Vector3()
    var sunIntensity: Float = 0
    var skyColor = Vector3()
    var skyIntensity: Float = 0
    var localLightIntensity: Float = 0
    var iblScale: Float = 0
    var iblSpecularScale: Float = 0
    var emissiveScale: Float = 0
    var scatterScale: Float = 0
    var wetness: Float = 0

    // Helper function to interpolate between lighting environments.
    static func interpolateLightingEnvironment(envA: Int, envB: Int, val: Float,
                                               lightEnvs: [XLightingEnvironment]) -> XLightingEnvironment {
        var env = XLightingEnvironment()
        env.exposure = lightEnvs[envA].exposure * (1.0 - val) + lightEnvs[envB].exposure * val
        env.sunColor = lightEnvs[envA].sunColor * (1.0 - val) + lightEnvs[envB].sunColor * val
        env.sunIntensity = lightEnvs[envA].sunIntensity * (1.0 - val) + lightEnvs[envB].sunIntensity * val
        env.skyColor = lightEnvs[envA].skyColor * (1.0 - val) + lightEnvs[envB].skyColor * val
        env.skyIntensity = lightEnvs[envA].skyIntensity * (1.0 - val) + lightEnvs[envB].skyIntensity * val
        env.localLightIntensity = lightEnvs[envA].localLightIntensity * (1.0 - val) + lightEnvs[envB].localLightIntensity * val
        env.iblScale = lightEnvs[envA].iblScale * (1.0 - val) + lightEnvs[envB].iblScale * val
        env.iblSpecularScale = lightEnvs[envA].iblSpecularScale * (1.0 - val) + lightEnvs[envB].iblSpecularScale * val
        env.emissiveScale = lightEnvs[envA].emissiveScale * (1.0 - val) + lightEnvs[envB].emissiveScale * val
        env.scatterScale = lightEnvs[envA].scatterScale * (1.0 - val) + lightEnvs[envB].scatterScale * val
        env.wetness = lightEnvs[envA].wetness * (1.0 - val) + lightEnvs[envB].wetness * val

        return env
    }
}

/// Encapsulates a lighting environment for the scene, which can be interpolated
///  between 2 other lighting environments.
class XLightingEnvironmentState {
    private static let LIGHT_ENV_DAY = 0
    private static let LIGHT_ENV_EVENING = 1
    private static let LIGHT_ENV_NIGHT = 2
    private static let LIGHT_ENV_COUNT = 3
    private static let INITIAL_LIGHT_ENV = XLightingEnvironmentState.LIGHT_ENV_NIGHT

    // A range of lighting environments.
    var _lightingEnvironments: [XLightingEnvironment] = .init(repeating: XLightingEnvironment(),
            count: XLightingEnvironmentState.LIGHT_ENV_COUNT)

    var _currentLightingEnvironment: XLightingEnvironment

    // Interpolation between loghting environments.
    var _currentLightingEnvironmentA: Int
    var _currentLightingEnvironmentB: Int
    var _currentLightingEnvironmentInterp: Float

    /// The current lighting environment.
    var currentEnvironment: XLightingEnvironment {
        _currentLightingEnvironment
    }

    var count: Int {
        XLightingEnvironmentState.LIGHT_ENV_COUNT
    }

    /// Initialize this state.
    init() {
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].exposure = 0.3
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].sunColor = Vector3(1, 1, 1)
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].sunIntensity = 10.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].skyColor = Vector3(65, 135, 255) / 255.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].skyIntensity = 2.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].localLightIntensity = 0.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].iblScale = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].iblSpecularScale = 4.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].emissiveScale = 0.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].scatterScale = 0.5
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_DAY].wetness = 0.0
        // ----------------------------------
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].exposure = 0.3
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].sunColor = Vector3(1, 0.5, 0.15)
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].sunIntensity = 10.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].skyColor = Vector3(200, 135, 255) / 255.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].skyIntensity = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].localLightIntensity = 0.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].iblScale = 0.5
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].iblSpecularScale = 4.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].emissiveScale = 0.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].scatterScale = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_EVENING].wetness = 0.0
        // ----------------------------------
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].exposure = 0.3
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].sunColor = Vector3(1, 1, 1)
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].sunIntensity = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].skyColor = Vector3(0, 35, 117) / 255.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].skyIntensity = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].localLightIntensity = 1.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].iblScale = 0.1
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].iblSpecularScale = 4.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].emissiveScale = 10.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].scatterScale = 2.0
        _lightingEnvironments[XLightingEnvironmentState.LIGHT_ENV_NIGHT].wetness = 1.0

        _currentLightingEnvironmentA = XLightingEnvironmentState.INITIAL_LIGHT_ENV
        _currentLightingEnvironmentB = XLightingEnvironmentState.INITIAL_LIGHT_ENV
        _currentLightingEnvironmentInterp = 0.0
        _currentLightingEnvironment = _lightingEnvironments[XLightingEnvironmentState.INITIAL_LIGHT_ENV]
    }

    /// Update the current lighting environment based on interpolation.
    func update() {
        _currentLightingEnvironment = XLightingEnvironment.interpolateLightingEnvironment(
                envA: _currentLightingEnvironmentA,
                envB: _currentLightingEnvironmentB,
                val: _currentLightingEnvironmentInterp,
                lightEnvs: _lightingEnvironments)
    }

    /// Skip to next lighting environment.
    func next() {
        _currentLightingEnvironmentA = (_currentLightingEnvironmentA + 1) % XLightingEnvironmentState.LIGHT_ENV_COUNT
        _currentLightingEnvironmentB = _currentLightingEnvironmentA
        _currentLightingEnvironmentInterp = 0.0

        assert(_currentLightingEnvironmentA < XLightingEnvironmentState.LIGHT_ENV_COUNT)
        assert(_currentLightingEnvironmentB < XLightingEnvironmentState.LIGHT_ENV_COUNT)
    }

    /// Configures the interpolation between environments a and b.
    func set(_ interp: Float, a: Int, b: Int) {
        _currentLightingEnvironmentA = a
        _currentLightingEnvironmentB = b
        _currentLightingEnvironmentInterp = interp
    }
}
