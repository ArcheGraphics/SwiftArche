//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Contains additional data to be used when rendering the scene.
///  This includes lights and occluder geometry.
class XScene {
    static let SPOT_LIGHT_INNER_SCALE: Float = 0.8

    var _device: MTLDevice
    var _name: String = ""
    var _pointLights: [XPointLightData] = []
    var _spotLights: [XSpotLightData] = []

    var _centerOffset = Vector3()
    var _occluderIndices: [Int] = []
    var _occluderVerts: [Vector3] = []
    var _occluderVertsTransformed: [Vector3] = []

    var meshFilename: String = ""

    var cameraPosition = Vector3()
    var cameraDirection = Vector3()
    var cameraUp = Vector3()

    var cameraKeypointsFilename: String = ""

    var sunDirection = Vector3()

    // Lights in the scene.
    var pointLights: XPointLightData {
        _pointLights[0]
    }
    var spotLights: XSpotLightData {
        _spotLights[0]
    }

    var pointLightCount: Int {
        _pointLights.count
    }
    var spotLightCount: Int {
        _spotLights.count
    }

    // Occluder geometry for the scene.
    var occluderVertexBuffer: MTLBuffer!
    var occluderIndexBuffer: MTLBuffer!

    init(with device: MTLDevice) {
        _device = device
    }

    /// Functions to add lights to the scene.
    func addPointLight(_ position: Vector3,
                       radius: Float,
                       color: Vector3,
                       flags: XLightType) {
        _pointLights.append(XPointLightData(posSqrRadius: simd_make_float4(position.internalValue, radius),
                color: color.internalValue, flags: flags.rawValue))
    }

    func addSpotLight(_ pos: Vector3,
                      dir: Vector3,
                      height: Float,
                      angle: Float,
                      color: Vector3,
                      flags: XLightType) {
        var spotLight = XSpotLightData()

        var boundingSphere = simd_float4()
        if angle > Float.pi / 4.0 {
            let R = height * tanf(angle)
            boundingSphere.xyz = pos.internalValue + height * dir.internalValue
            boundingSphere.w = R
        } else {
            let R = height / (2 * cos(angle) * cos(angle))
            boundingSphere.xyz = pos.internalValue + dir.internalValue * R
            boundingSphere.w = R
        }
        spotLight.boundingSphere = boundingSphere
        spotLight.dirAndOuterAngle = simd_make_float4(dir.internalValue, angle)
        spotLight.posAndHeight = simd_make_float4(pos.internalValue, height)
        spotLight.colorAndInnerAngle = simd_make_float4(color.internalValue, angle * XScene.SPOT_LIGHT_INNER_SCALE)
        spotLight.flags = flags.rawValue

        let spotNearClip: Float = 0.1
        let spotFarClip: Float = height
        let viewMatrix = Matrix.lookAt(eye: pos, target: pos + dir, up: Vector3(0, 1, 0))
        let va_tan = 1.0 / tanf(angle * 2.0 * 0.5)
        let ys = va_tan
        let xs = ys
        let zs = spotFarClip / (spotFarClip - spotNearClip)
        let projMatrix = float4x4(
                SIMD4<Float>(xs, 0, 0, 0),
                SIMD4<Float>(0, ys, 0, 0),
                SIMD4<Float>(0, 0, zs, 1),
                SIMD4<Float>(0, 0, -spotNearClip * zs, 0))

        spotLight.viewProjMatrix = projMatrix * viewMatrix.elements

        _spotLights.append(spotLight)
    }

    func clearLights() {
        _spotLights = []
        _pointLights = []
    }
}
