//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_render

/// sdf Material.
public class ImplicitTriangleMaterial: BaseMaterial {
    private static let sdfProperty = "u_sdfData"
    private static let sdfTextureProperty = "u_sdfTexture"
    private static let sdfSamplerProperty = "u_sdfSampler"
    private var _sdfData = SDFData()
    private var _mesh: ImplicitTriangleMesh?

    /// sdf mesh.
    public var mesh: ImplicitTriangleMesh? {
        get {
            _mesh
        }
        set {
            _mesh = newValue
            if let mesh = _mesh {
                _sdfData.SDFUpper = mesh.upper
                _sdfData.SDFLower = mesh.lower
                _sdfData.SDFExtent = mesh.extend
                shaderData.setImageView(ImplicitTriangleMaterial.sdfTextureProperty, ImplicitTriangleMaterial.sdfSamplerProperty, mesh.sdf!)
                shaderData.setData(ImplicitTriangleMaterial.sdfProperty, _sdfData)
            }
        }
    }
    
    public var absThreshold: Float {
        get {
            _sdfData.AbsThreshold
        }
        set {
            _sdfData.AbsThreshold = newValue
            shaderData.setData(ImplicitTriangleMaterial.sdfProperty, _sdfData)
        }
    }
    
    public var maxTraceSteps: UInt32 {
        get {
            _sdfData.MaxTraceSteps
        }
        set {
            _sdfData.MaxTraceSteps = newValue
            shaderData.setData(ImplicitTriangleMaterial.sdfProperty, _sdfData)
        }
    }

    public override init(_ engine: Engine, _ name: String = "") {
        super.init(engine, name)
        shader.append(ShaderPass(engine.library("flex.shader"), "vertex_sdf", "fragment_sdf"))

        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
        
        _sdfData.AbsThreshold = 0.001;
        _sdfData.MaxTraceSteps = 2;
        shaderData.setData(ImplicitTriangleMaterial.sdfProperty, _sdfData)
    }
}
