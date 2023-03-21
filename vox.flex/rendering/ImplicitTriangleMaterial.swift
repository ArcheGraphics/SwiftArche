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
    private static let absThresholdProperty = "u_absThreshold"
    private static let maxTraceStepsProperty = "u_maxTraceSteps"
    private static let sdfTextureProperty = "u_sdfTexture"
    private static let sdfSamplerProperty = "u_sdfSampler"
    private var _sdf: ImplicitTriangleMesh?
    private var _absThreshold: Float = 0.001
    private var _maxTraceSteps: UInt32 = 2
    
    /// sdf mesh.
    public var sdf: ImplicitTriangleMesh? {
        get {
            _sdf
        }
        set {
            _sdf = newValue
            if let sdf = _sdf {
                shaderData.setImageView(ImplicitTriangleMaterial.sdfTextureProperty, ImplicitTriangleMaterial.sdfSamplerProperty, sdf.sdf!)
                shaderData.setSampler(ImplicitTriangleMaterial.sdfSamplerProperty, sdf.sdfSampler)
                shaderData.setData(ImplicitTriangleMaterial.sdfProperty, sdf.data)
            }
        }
    }
    
    public var absThreshold: Float {
        get {
            _absThreshold
        }
        set {
            _absThreshold = newValue
            shaderData.setData(ImplicitTriangleMaterial.absThresholdProperty, newValue)
        }
    }
    
    public var maxTraceSteps: UInt32 {
        get {
            _maxTraceSteps
        }
        set {
            _maxTraceSteps = newValue
            shaderData.setData(ImplicitTriangleMaterial.maxTraceStepsProperty, newValue)
        }
    }

    public override init(_ name: String = "implicit triangle mat") {
        super.init(name)
        shader.append(ShaderPass(Engine.library("flex.shader"), "vertex_sdf", "fragment_sdf"))

        shaderData.enableMacro(OMIT_NORMAL.rawValue)
        shaderData.enableMacro(NEED_TILINGOFFSET.rawValue)
        
        shaderData.setData(ImplicitTriangleMaterial.absThresholdProperty, _absThreshold)
        shaderData.setData(ImplicitTriangleMaterial.maxTraceStepsProperty, _maxTraceSteps)
    }
}
