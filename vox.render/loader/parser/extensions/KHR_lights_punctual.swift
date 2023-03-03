//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class KHR_lights_punctual {
    static func parseEngineResource(_ schema: GLTFLight, _ entity: Entity, _ context: ParserContext) {
        let light: Light
        switch schema.type {
        case .directional:
            light = entity.addComponent(DirectLight.self)
            break
        case .point:
            let l = entity.addComponent(PointLight.self)
            l.distance = schema.range
            light = l
            break
        case .spot:
            let l = entity.addComponent(SpotLight.self)
            l.distance = schema.range
            l.angle = schema.innerConeAngle
            l.penumbra = schema.outerConeAngle - schema.innerConeAngle
            light = l
            break
        @unknown default:
            return
        }

        light.color = Color(schema.color.x, schema.color.y, schema.color.z, 1)
        light.intensity = schema.intensity

        if (context.glTFResource.lights == nil) {
            context.glTFResource.lights = []
        }
        context.glTFResource.lights!.append(light)
    }
}
