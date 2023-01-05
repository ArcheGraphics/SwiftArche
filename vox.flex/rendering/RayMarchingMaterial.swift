//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

/// sdf Material.
public class RayMarchingMaterial: BaseMaterial {
    private var _capsuleColliderShapes: ParticleCapsuleCollider?
    
    public var capsuleColliderShapes: ParticleCapsuleCollider? {
        get {
            _capsuleColliderShapes
        }
        set {
            _capsuleColliderShapes = newValue
            if let capsuleColliderShapes = _capsuleColliderShapes {
                shaderData.setData("u_capsules", capsuleColliderShapes.capsuleData)
                shaderData.setData("u_count", UInt(capsuleColliderShapes.capsuleData.count))
            }
        }
    }
    
    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("flex.shader"), "vertex_rayMarching", "fragment_rayMarching"))

        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
    }
}
