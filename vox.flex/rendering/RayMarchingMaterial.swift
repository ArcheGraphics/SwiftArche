//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

/// ray marching Material.
public class RayMarchingMaterial: BaseMaterial {
    static private var _rayMarchingProperty = "u_rayMarching"
    private var _capsuleColliderShapes: ParticleCapsuleCollider?
    private var _rayMarchingData: RayMarchingData
    
    public var color: Vector3F {
        get {
            _rayMarchingData.color
        }
        set {
            _rayMarchingData.color = newValue
            shaderData.setData(RayMarchingMaterial._rayMarchingProperty, _rayMarchingData)
        }
    }
    
    public var direction: Vector3F {
        get {
            _rayMarchingData.direction
        }
        set {
            _rayMarchingData.direction = newValue
            shaderData.setData(RayMarchingMaterial._rayMarchingProperty, _rayMarchingData)
        }
    }
    
    public var iteration: UInt32 {
        get {
            _rayMarchingData.iteration
        }
        set {
            _rayMarchingData.iteration = newValue
            shaderData.setData(RayMarchingMaterial._rayMarchingProperty, _rayMarchingData)
        }
    }
    
    public var tol: Float {
        get {
            _rayMarchingData.tol
        }
        set {
            _rayMarchingData.tol = newValue
            shaderData.setData(RayMarchingMaterial._rayMarchingProperty, _rayMarchingData)
        }
    }
    
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
        _rayMarchingData = RayMarchingData(color: Vector3(1, 1, 1), iteration: 32, direction: Vector3(0, 1, 0), tol: 0.001)
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("flex.shader"), "vertex_rayMarching", "fragment_rayMarching"))
        shaderData.setData(RayMarchingMaterial._rayMarchingProperty, _rayMarchingData)
        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
    }
}
