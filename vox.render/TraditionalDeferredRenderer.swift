//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

// MARK: - TraditionalDeferredRenderer

public class TraditionalDeferredRenderer: Renderer {
    public init(device: MTLDevice,
         scene: Scene,
         renderDestination: RenderDestination,
         didBeginFrame: @escaping () -> Void) {

        super.init(device: device,
                scene: scene,
                renderDestination: renderDestination,
                singlePass: false,
                didBeginFrame: didBeginFrame)
    }

    let gBufferPassDescriptor: MTLRenderPassDescriptor = {
        let descriptor = MTLRenderPassDescriptor()
        // Depth and Stencil attachments are needed in next pass, so need to store them (since the default is .dontCare).
        descriptor.depthAttachment.storeAction = .store
        descriptor.stencilAttachment.storeAction = .store
        return descriptor
    }()

    let lightingPassDescriptor: MTLRenderPassDescriptor = {
        let descriptor = MTLRenderPassDescriptor()
        // Depth and Stencil attachments are needed from previous pass, so need to load them (since the default is .clear).
        descriptor.depthAttachment.loadAction = .load
        descriptor.stencilAttachment.loadAction = .load
        return descriptor
    }()
}

// MARK: - MTKViewDelegate

extension TraditionalDeferredRenderer {
    public override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TraditionalDeferredRenderer uses private GBuffer render targets.
        drawableSizeWillChange?(view.device!, size, .private)

        // Re-set GBuffer textures in the GBuffer render pass descriptor after they have been reallocated by a resize
        setGBufferTextures(gBufferPassDescriptor)

        // Cannot set the depth stencil texture here since MTKView reallocates it *after* the drawableSizeWillChange callback

        // Draw once even though the view is paused to make sure the scene does not appear stretched.
        if view.isPaused {
            view.draw()
        }
    }

    public override func draw(in view: MTKView) {
        var commandBuffer = beginFrame()
        commandBuffer.label = "Shadow & GBuffer Commands"

        // MARK: - Shadow Map Pass
        encodeShadowMapPass(into: commandBuffer)

        // MARK: - GBuffer Generation Pass
        gBufferPassDescriptor.depthAttachment.texture = view.depthStencilTexture
        gBufferPassDescriptor.stencilAttachment.texture = view.depthStencilTexture

        encodePass(into: commandBuffer,
                using: gBufferPassDescriptor,
                label: "GBuffer Generation Pass") { renderEncoder in

            encodeGBufferStage(using: renderEncoder)
        }

        // Commit commands so that Metal can begin working on non-drawable dependant work without
        // waiting for a drawable to become avaliable
        commandBuffer.commit()

        commandBuffer = beginDrawableCommands()
        commandBuffer.label = "Lighting Commands"

        // MARK: - Lighting Pass
        // The final pass can only render if a drawable is available, otherwise it needs to skip
        // rendering this frame.
        if let drawableTexture = view.currentDrawable?.texture {
            lightingPassDescriptor.colorAttachments[Int(AAPLRenderTargetLighting.rawValue)].texture = drawableTexture
            lightingPassDescriptor.depthAttachment.texture = view.depthStencilTexture
            lightingPassDescriptor.stencilAttachment.texture = view.depthStencilTexture

            encodePass(into: commandBuffer,
                    using: lightingPassDescriptor,
                    label: "Lighting Pass") { (renderEncoder) in

                encodeDirectionalLightingStage(using: renderEncoder)
                encodeLightMaskStage(using: renderEncoder)
                encodePointLightStage(using: renderEncoder)
                encodeSkyboxStage(using: renderEncoder)
                encodeFairyBillboardStage(using: renderEncoder)
            }
        }

        endFrame(commandBuffer)
    }

}
