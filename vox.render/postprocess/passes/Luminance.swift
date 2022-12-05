//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class Luminance: ComputePass {
    // Target for luminance calculation is fixed at 1/8 the number of pixels of native resolution.
    private let kLogLuminanceTargetScale: Float = 0.25
    private let device: MTLDevice
    private var _logLuminanceTexture: MTLTexture!
    private var _canvasChanged: Canvas?

    var logLuminanceTexture: MTLTexture {
        get {
            _logLuminanceTexture
        }
    }

    init(_ scene: Scene) {
        let engine = scene.engine
        device = engine.device
        super.init(engine)

        let canvas = engine.canvas
        let flag = ListenerUpdateFlag()
        flag.listener = resize
        canvas.updateFlagManager.addFlag(flag: flag)
        if let renderTarget = canvas.currentRenderPassDescriptor,
           let texture = renderTarget.colorAttachments[0].texture {
            createTexture(texture.width, texture.height)
        }

        shader.append(ShaderPass(engine.library(), "logLuminance"))
    }

    func resize(type: Int?, param: AnyObject?) -> Void {
        _canvasChanged = (param as! Canvas) // wait update until next frame
    }

    func createTexture(_ width: Int, _ height: Int) {
        let width = Int(Float(width) * kLogLuminanceTargetScale)
        let height = Int(Float(height) * kLogLuminanceTargetScale)
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r16Float, width: width, height: height, mipmapped: true)
        desc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        desc.storageMode = .private
        _logLuminanceTexture = device.makeTexture(descriptor: desc)
        defaultShaderData.setImageView("output", _logLuminanceTexture)

        threadsPerGridX = width
        threadsPerGridY = height
    }
    
    public override func compute(commandEncoder: MTLComputeCommandEncoder) {
        if let canvas = _canvasChanged {
            if let renderTarget = canvas.currentRenderPassDescriptor,
               let texture = renderTarget.colorAttachments[0].texture {
                createTexture(texture.width, texture.height)
                _canvasChanged = nil
            }
        }
        
        super.compute(commandEncoder: commandEncoder)
    }
}
