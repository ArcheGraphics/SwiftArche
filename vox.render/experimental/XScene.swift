//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Contains additional data to be used when rendering the scene.
///  This includes lights and occluder geometry.
class XScene: Codable {
    static let SPOT_LIGHT_INNER_SCALE: Float = 0.8

    var _device: MTLDevice
    var _name: String = ""
    var _pointLights: [XPointLightData] = []
    var _spotLights: [XSpotLightData] = []

    var _centerOffset = Vector3()
    var _occluderIndices: [UInt16] = []
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

// MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case center_offset
        
        case mesh_filename
        case camera_position
        case camera_direction
        case camera_up
        case camera_keypoints_filename
        case sun_direction
        
        case point_lights
        case spot_lights
        
        case occluder_verts
        case occluder_indices
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_centerOffset, forKey: .center_offset)
        
        try container.encode(meshFilename, forKey: .mesh_filename)
        try container.encode(cameraPosition, forKey: .camera_position)
        try container.encode(cameraDirection, forKey: .camera_direction)
        try container.encode(cameraUp, forKey: .camera_up)
        try container.encode(cameraKeypointsFilename, forKey: .camera_keypoints_filename)
        try container.encode(sunDirection, forKey: .sun_direction)
        
        try container.encode(_pointLights, forKey: .point_lights)
        try container.encode(_spotLights, forKey: .spot_lights)

        try container.encode(_occluderVerts, forKey: .occluder_verts)
        try container.encode(_occluderIndices, forKey: .occluder_indices)
    }
    
    required init(from decoder: Decoder) throws {
        _device = Engine.device
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _centerOffset = try container.decode(Vector3.self, forKey: .center_offset)

        meshFilename = try container.decode(String.self, forKey: .mesh_filename)
        cameraPosition = try container.decode(Vector3.self, forKey: .camera_position)
        cameraDirection = try container.decode(Vector3.self, forKey: .camera_direction)
        cameraUp = try container.decode(Vector3.self, forKey: .camera_up)
        cameraKeypointsFilename = try container.decode(String.self, forKey: .camera_keypoints_filename)
        sunDirection = try container.decode(Vector3.self, forKey: .sun_direction)

        _pointLights = try container.decode([XPointLightData].self, forKey: .point_lights)
        _spotLights = try container.decode([XSpotLightData].self, forKey: .spot_lights)
        
        _occluderVerts = try container.decode([Vector3].self, forKey: .occluder_verts)
        for i in 0..<_occluderVerts.count {
            var transformedVert = _occluderVerts[i];
            let t             = transformedVert.z;
            transformedVert.z   = transformedVert.y;
            transformedVert.y   = t;

            transformedVert -= _centerOffset;

            _occluderVertsTransformed.append(transformedVert);
        }
        _occluderIndices = try container.decode([UInt16].self, forKey: .occluder_indices)

        let vertexBufferSize = MemoryLayout<Vector3>.stride * _occluderVertsTransformed.count
        occluderVertexBuffer = _device.makeBuffer(bytes: _occluderVerts, length: vertexBufferSize)
        occluderVertexBuffer.label = "Occluder Vertices"
        
        let indexBufferSize  = MemoryLayout<UInt16>.stride * _occluderIndices.count
        occluderIndexBuffer = _device.makeBuffer(bytes: _occluderIndices, length: indexBufferSize)
        occluderIndexBuffer.label = "Occluder Indices"
    }
}

extension XPointLightData: Codable {
    enum CodingKeys: String, CodingKey {
        case position_x
        case position_y
        case position_z
        case sqrt_radius
        case color_r
        case color_g
        case color_b
        case for_transparent
    }

    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        posSqrRadius.x = try container.decode(Float.self, forKey: .position_x)
        posSqrRadius.y = try container.decode(Float.self, forKey: .position_y)
        posSqrRadius.z = try container.decode(Float.self, forKey: .position_z)
        posSqrRadius.w = try container.decode(Float.self, forKey: .sqrt_radius)

        color.x = try container.decode(Float.self, forKey: .color_r)
        color.y = try container.decode(Float.self, forKey: .color_g)
        color.z = try container.decode(Float.self, forKey: .color_b)
        let flag = try container.decode(Bool.self, forKey: .for_transparent)
        if flag {
            flags = uint(XLightType.LightForTransparent.rawValue)
        } else {
            flags = 0
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(posSqrRadius.x, forKey: .position_x)
        try container.encode(posSqrRadius.y, forKey: .position_y)
        try container.encode(posSqrRadius.z, forKey: .position_z)
        try container.encode(posSqrRadius.w, forKey: .sqrt_radius)
        
        try container.encode(color.x, forKey: .color_r)
        try container.encode(color.y, forKey: .color_g)
        try container.encode(color.z, forKey: .color_b)
        let flags = XLightType(rawValue: flags)
        try container.encode(flags.contains(.LightForTransparent), forKey: .for_transparent)
    }
}

extension XSpotLightData: Codable {
    enum CodingKeys: String, CodingKey {
        case position_x
        case position_y
        case position_z
        case height
        
        case direction_x
        case direction_y
        case direction_z
        case coneRad
        
        case color_r
        case color_g
        case color_b
        case for_transparent
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        posAndHeight.x = try container.decode(Float.self, forKey: .position_x)
        posAndHeight.y = try container.decode(Float.self, forKey: .position_y)
        posAndHeight.z = try container.decode(Float.self, forKey: .position_z)
        posAndHeight.w = try container.decode(Float.self, forKey: .height)
        
        dirAndOuterAngle.x = try container.decode(Float.self, forKey: .direction_x)
        dirAndOuterAngle.y = try container.decode(Float.self, forKey: .direction_y)
        dirAndOuterAngle.z = try container.decode(Float.self, forKey: .direction_z)
        dirAndOuterAngle.w = try container.decode(Float.self, forKey: .coneRad)

        colorAndInnerAngle.x = try container.decode(Float.self, forKey: .color_r)
        colorAndInnerAngle.y = try container.decode(Float.self, forKey: .color_g)
        colorAndInnerAngle.z = try container.decode(Float.self, forKey: .color_b)
        let flag = try container.decode(Bool.self, forKey: .for_transparent)
        if flag {
            flags = uint(XLightType.LightForTransparent.rawValue)
        } else {
            flags = 0
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(posAndHeight.x, forKey: .position_x)
        try container.encode(posAndHeight.y, forKey: .position_y)
        try container.encode(posAndHeight.z, forKey: .position_z)
        try container.encode(posAndHeight.w, forKey: .height)

        try container.encode(dirAndOuterAngle.x, forKey: .direction_x)
        try container.encode(dirAndOuterAngle.y, forKey: .direction_y)
        try container.encode(dirAndOuterAngle.z, forKey: .direction_z)
        try container.encode(dirAndOuterAngle.w, forKey: .coneRad)
        
        try container.encode(colorAndInnerAngle.x, forKey: .color_r)
        try container.encode(colorAndInnerAngle.y, forKey: .color_g)
        try container.encode(colorAndInnerAngle.z, forKey: .color_b)
        let flags = XLightType(rawValue: flags)
        try container.encode(flags.contains(.LightForTransparent), forKey: .for_transparent)
    }
}
