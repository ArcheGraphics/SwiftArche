//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

public class ForwardSubpass: GeometrySubpass {
    var textBatcher: TextBatcher!
    
    override func setRenderPass(_ renderPass: RenderPass) {
        super.setRenderPass(renderPass)
        textBatcher = TextBatcher(renderPass.pipeline.camera.engine)
    }
    
    public override func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                                 _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "Forward Pipeline"
        pipelineDescriptor.colorAttachments[0].pixelFormat = Canvas.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = Canvas.depthPixelFormat
        if let format = Canvas.stencilPixelFormat  {
            pipelineDescriptor.stencilAttachmentPixelFormat = format
        }
    }

    public override func drawElement(_ encoder: inout RenderCommandEncoder) {
        let pipeline = _renderPass.pipeline!
        pipeline._opaqueQueue.removeAll()
        pipeline._alphaTestQueue.removeAll()
        pipeline._transparentQueue.removeAll()
        pipeline.callRender(pipeline.camera._cameraInfo)
        pipeline._opaqueQueue.sort(by: DevicePipeline._compareFromNearToFar)
        pipeline._alphaTestQueue.sort(by: DevicePipeline._compareFromNearToFar)
        pipeline._transparentQueue.sort(by: DevicePipeline._compareFromFarToNear)

        // opaque
        for element in pipeline._opaqueQueue {
            if element.renderer is TextRenderer {
                textBatcher.appendElement(element)
            } else {
                super._drawElement(&encoder, element)
            }
        }
        super._drawBatcher(&encoder, textBatcher)
        
        // alphaTest
        for element in pipeline._alphaTestQueue {
            if element.renderer is TextRenderer {
                textBatcher.appendElement(element)
            } else {
                super._drawElement(&encoder, element)
            }
        }
        super._drawBatcher(&encoder, textBatcher)

        // transparent
        for element in pipeline._transparentQueue {
            if element.renderer is TextRenderer {
                textBatcher.appendElement(element)
            } else {
                super._drawElement(&encoder, element)
            }
        }
        super._drawBatcher(&encoder, textBatcher)
    }
}
