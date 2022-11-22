//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class KHR_lights_punctual {
    static func parseEngineResource(_ schema: GLTFLight, _ entity: Entity, _ context: ParserContext) {
        let light: Light
        switch schema.type {
        case .directional:
            let l: DirectLight = entity.addComponent()
            light = l
            break
        case .point:
            let l: PointLight = entity.addComponent()
            l.distance = schema.range
            light = l
            break
        case .spot:
            let l: SpotLight = entity.addComponent()
            l.distance = schema.range
            l.angle = schema.innerConeAngle
            l.penumbra = schema.outerConeAngle - schema.innerConeAngle
            light = l
            break
        @unknown default:
            return
        }

        _ = light.color.set(r: schema.color.x, g: schema.color.y, b: schema.color.z, a: 1)
        light.intensity = schema.intensity

        if (context.glTFResource.lights == nil) {
            context.glTFResource.lights = []
        }
        context.glTFResource.lights!.append(light)
    }
}