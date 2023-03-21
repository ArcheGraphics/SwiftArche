//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class PostprocessManager {
    public var resourceCache: ResourceCache
    var _canvas: Canvas
    weak var _scene: Scene!
    var _shaderData: ShaderData
    var _postprocessData = PostprocessData(manualExposureValue: 0.5, exposureKey: 0.25)
    var _autoExposure: Bool = false

    // default pass
    public var postProcessPass: ComputePass!
    public var luminancePass: Luminance?
    public var computePasses: [ComputePass] = []

    /// manual exposure
    public var manualExposure: Float {
        get {
            _postprocessData.manualExposureValue
        }
        set {
            _postprocessData.manualExposureValue = newValue
            _shaderData.setData("u_postprocess", _postprocessData)
        }
    }

    /// exposure key used in auto mode
    public var exposureKey: Float {
        get {
            _postprocessData.exposureKey
        }
        set {
            _postprocessData.exposureKey = newValue
            _shaderData.setData("u_postprocess", _postprocessData)
        }
    }

    // enable auto exposure
    public var autoExposure: Bool {
        get {
            _autoExposure
        }
        set {
            _autoExposure = newValue
            if newValue {
                luminancePass = Luminance(_scene)
                luminancePass!.resourceCache = resourceCache
                _shaderData.enableMacro(IS_AUTO_EXPOSURE.rawValue)
            } else {
                luminancePass = nil
                _shaderData.disableMacro(IS_AUTO_EXPOSURE.rawValue)
            }
        }
    }

    init(_ scene: Scene) {
        _scene = scene
        _canvas = Engine.canvas!
        resourceCache = ResourceCache(Engine.device)
        _shaderData = scene.shaderData
        _shaderData.setData("u_postprocess", _postprocessData)

        postProcessPass = ComputePass()
        postProcessPass.resourceCache = resourceCache
        postProcessPass.shader.append(ShaderPass(Engine.library(), "postprocess_merge"))
        postProcessPass.data.append(_shaderData)
    }

    public func registerComputePass(_ pass: ComputePass) {
        pass.resourceCache = resourceCache
        computePasses.append(pass)
    }

    func render(_ commandBuffer: MTLCommandBuffer) {
        for pass in computePasses {
            if let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() {
                pass.compute(commandEncoder: computeCommandEncoder)
                computeCommandEncoder.endEncoding()
            }
        }

        if let renderTarget = _canvas.currentRenderPassDescriptor {
            let texture = renderTarget.colorAttachments[0].texture!
            if let luminancePass = luminancePass,
               let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                computeEncoder.label = "luminance approximation"
                luminancePass.defaultShaderData.setImageView("input", texture)
                postProcessPass.defaultShaderData.setImageView("logLuminanceIn", luminancePass.logLuminanceTexture)
                luminancePass.compute(commandEncoder: computeEncoder)
                computeEncoder.endEncoding()
                
                // must generate
                let blit = commandBuffer.makeBlitCommandEncoder()!
                blit.generateMipmaps(for: luminancePass.logLuminanceTexture)
                blit.endEncoding()
            }

            if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                computeEncoder.label = "gamme correction"
                postProcessPass.threadsPerGridX = texture.width
                postProcessPass.threadsPerGridY = texture.height
                postProcessPass.defaultShaderData.setImageView("framebufferInput", texture)
                postProcessPass.defaultShaderData.setImageView("framebufferOutput", texture)
                postProcessPass.compute(commandEncoder: computeEncoder)
                computeEncoder.endEncoding()
            }
        }
    }
}
