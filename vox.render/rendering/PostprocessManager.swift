//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class PostprocessManager {
    var _resourceCache: ResourceCache
    var _canvas: Canvas
    var _shaderData: ShaderData
    var _manualExposure: Float = 1.0
    
    // default pass
    public var postProcessPass: ComputePass!
    public var computePasses: [ComputePass] = []

    /// Tone Mapping exposure
    public var manualExposure: Float {
        get {
            _manualExposure
        }
        set {
            _manualExposure = newValue
            _shaderData.setData("u_exposure", newValue)
        }
    }

    init(_ engine: Engine) {
        _canvas = engine.canvas
        _resourceCache = ResourceCache(engine.device)
        _shaderData = ShaderData(engine.device)
        
        postProcessPass = ComputePass(engine.device)
        postProcessPass.resourceCache = _resourceCache
        postProcessPass.shader.append(ShaderPass(engine.library(), "postprocess_merge"))
        postProcessPass.data.append(_shaderData)
        
        manualExposure = 1.0
    }
    
    public func registerComputePass(_ pass: ComputePass) {
        pass.resourceCache = _resourceCache
        computePasses.append(pass)
    }
    
    func render(_ commandBuffer: MTLCommandBuffer) {
        for pass in computePasses {
            if let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() {
                pass.compute(commandEncoder: computeCommandEncoder)
                computeCommandEncoder.endEncoding()
            }
        }
        
        if let renderTarget = _canvas.currentRenderPassDescriptor ,
           let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            let texture = renderTarget.colorAttachments[0].texture!
            postProcessPass.threadsPerGridX = texture.width
            postProcessPass.threadsPerGridY = texture.height
            postProcessPass.defaultShaderData.setImageView("framebufferInput", texture)
            postProcessPass.defaultShaderData.setImageView("framebufferOutput", texture)
            postProcessPass.compute(commandEncoder: computeEncoder)
            computeEncoder.endEncoding()
        }
    }
}
