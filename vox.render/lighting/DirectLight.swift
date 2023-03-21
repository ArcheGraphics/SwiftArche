//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Directional light.
public class DirectLight: Light {
    private static let _directLightProperty = "u_directLight"
    private static var _combinedData: [DirectLightData] = [DirectLightData](repeating: DirectLightData(), count: Light._maxLight)

    static func _updateShaderData(_ shaderData: ShaderData) {
        shaderData.setData(DirectLight._directLightProperty, DirectLight._combinedData)
    }

    /// Get direction.
    public var direction: Vector3 {
        get {
            entity.transform.worldForward
        }
    }

    /// Get the opposite direction of the directional light direction.
    public var reverseDirection: Vector3 {
        get {
            direction * -1
        }
    }

    func _appendData(_ lightIndex: Int) {
        DirectLight._combinedData[lightIndex].color = _getLightColor()
        DirectLight._combinedData[lightIndex].direction = direction.internalValue
    }

    override func _onEnable() {
        Engine._lightManager._attachDirectLight(self)
    }

    override func _onDisable() {
        Engine._lightManager._detachDirectLight(self)
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
