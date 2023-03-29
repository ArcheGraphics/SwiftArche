//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class GammaCorrection: ComputePass {
    public var autoExposure: Bool = false

    final class GammaEncoderData: EmptyClassType {
        var input: Resource<MTLTextureDescriptor>?
        var luminance: Resource<MTLTextureDescriptor>?
        var output: Resource<MTLTextureDescriptor>?
        required init() {}
    }

    override init(_ scene: Scene) {
        super.init(scene)
        shader.append(ShaderPass(Engine.library(), "postprocess_merge"))
    }
    
    public func compute(with commandBuffer: MTLCommandBuffer,
                        luminance: Resource<MTLTextureDescriptor>? = nil, label: String = "") {
        Engine.fg.addRenderTask(for: GammaEncoderData.self, name: "gamma correction") { [self] data, builder in
            if autoExposure {
                data.luminance = builder.read(resource: luminance!)
            }
            
            let colorTex = Engine.fg.blackboard[BlackBoardType.color.rawValue] as! Resource<MTLTextureDescriptor>
            data.input = builder.read(resource: colorTex)
            data.output = builder.write(resource: colorTex)
        } execute: { [self] builder in
            let colorTex = builder.output!.actual!
            if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                commandEncoder.label = label
                threadsPerGridX = colorTex.width
                threadsPerGridY = colorTex.height

                Engine.fg.shaderData.setImageView("framebufferInput", builder.input?.actual)
                Engine.fg.shaderData.setImageView("framebufferOutput", builder.output?.actual)
                if autoExposure {
                    Engine.fg.shaderData.setImageView("logLuminanceIn", builder.luminance?.actual)
                }
                compute(commandEncoder: commandEncoder, label: label)
                commandEncoder.endEncoding()
            }
        }
    }
}
