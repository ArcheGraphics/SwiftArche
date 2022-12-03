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
    var _manualExposure: Float = 0.5
    
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

    init(_ scene: Scene) {
        _canvas = scene.engine.canvas
        let device = scene.engine.device
        _resourceCache = ResourceCache(device)
        _shaderData = scene.shaderData
        
        postProcessPass = ComputePass(device)
        postProcessPass.resourceCache = _resourceCache
        postProcessPass.shader.append(ShaderPass(scene.engine.library(), "postprocess_merge"))
        postProcessPass.data.append(_shaderData)
        
        manualExposure = 0.5
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
