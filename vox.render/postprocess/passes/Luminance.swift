//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class Luminance: ComputePass {
    // Target for luminance calculation is fixed at 1/8 the number of pixels of native resolution.
    private let kLogLuminanceTargetScale: Float = 0.25
    private var desc = MTLTextureDescriptor()

    public final class LuminanceEncoderData: EmptyClassType {
        var input: Resource<MTLTextureDescriptor>?
        var output: Resource<MTLTextureDescriptor>?
        public required init() {}
    }

    override init(_ scene: Scene) {
        super.init(scene)
        shader.append(ShaderPass(Engine.library(), "logLuminance"))
        desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r16Float,
                                                        width: 256, height: 256, mipmapped: true)
        desc.usage = [.shaderRead, .shaderWrite]
        desc.storageMode = .private
    }

    func updateTexture(_ width: Int, _ height: Int) {
        let width = Int(Float(width) * kLogLuminanceTargetScale)
        let height = Int(Float(height) * kLogLuminanceTargetScale)
        desc.width = width
        desc.height = height

        threadsPerGridX = width
        threadsPerGridY = height
    }

    public func compute(with commandBuffer: MTLCommandBuffer, label: String = "") -> LuminanceEncoderData {
        return Engine.fg.addFrameTask(for: LuminanceEncoderData.self, name: "luminance", commandBuffer: commandBuffer) {
            [self] data, builder in
            let colorTex = Engine.fg.blackboard[BlackBoardType.color.rawValue] as! Resource<MTLTextureDescriptor>
            updateTexture(colorTex.actual!.width, colorTex.actual!.height)

            data.input = builder.read(resource: colorTex)
            data.output = builder.write(resource: builder.create(name: "luminanceTex", description: desc))
        } execute: { builder, commandBuffer in
            if let commandBuffer,
               let luminanceTex = builder.output?.actual
            {
                if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
                    commandEncoder.label = label
                    Engine.fg.frameData.enableMacro(IS_AUTO_EXPOSURE.rawValue)
                    Engine.fg.frameData.setImageView("input", builder.input?.actual)
                    Engine.fg.frameData.setImageView("output", luminanceTex)
                    super.compute(commandEncoder: commandEncoder, label: label)
                    commandEncoder.endEncoding()
                }

                let blit = commandBuffer.makeBlitCommandEncoder()!
                blit.generateMipmaps(for: luminanceTex)
                blit.endEncoding()
            }
        }.data
    }

    override public func compute(commandEncoder _: MTLComputeCommandEncoder, label _: String = "") {}
}
