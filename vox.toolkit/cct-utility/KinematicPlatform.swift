//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

public class KinematicPlatform : Script {
    var time: Float = 0
    var platform: DynamicCollider?
    
    required init(_ entity: Entity) {
        platform = entity.getComponent(DynamicCollider.self)
        if let platform {
            platform.isKinematic = true
            platform.setDensity(1)
        }
        super.init(entity)
    }

    public override func onUpdate(_ deltaTime: Float) {
        time += deltaTime
        if let platform {
            platform.movePosition(Vector3(sin(time) * 15, sin(time) * 2 + 3, cos(time) * 15))
        }
    }
}
