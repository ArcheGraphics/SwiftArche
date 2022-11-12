//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import vox_math

/// Blend state.
public class BlendState {
    /// The blend state of the render target.
    public var targetBlendState: RenderTargetBlendState = RenderTargetBlendState()
    /// Constant blend color.
    public var blendColor: Color = Color(0, 0, 0, 0)
    /// Whether to use (Alpha-to-Coverage) technology.
    public var alphaToCoverage: Bool = false

    func _apply(_ pipelineDescriptor: MTLRenderPipelineDescriptor,
                _ renderEncoder: MTLRenderCommandEncoder) {
        let enabled = targetBlendState.enabled
        if (enabled) {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        } else {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = false
        }

        if (enabled) {
            // apply blend factor.
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = targetBlendState.sourceColorBlendFactor
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = targetBlendState.destinationColorBlendFactor
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = targetBlendState.sourceAlphaBlendFactor
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = targetBlendState.destinationAlphaBlendFactor

            // apply blend operation.
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = targetBlendState.colorBlendOperation
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = targetBlendState.alphaBlendOperation

            // apply blend color.
            renderEncoder.setBlendColor(red: blendColor.r, green: blendColor.g, blue: blendColor.b, alpha: blendColor.a)
        }

        // apply color mask.
        pipelineDescriptor.colorAttachments[0].writeMask = targetBlendState.colorWriteMask

        // apply alpha to coverage.
        if (alphaToCoverage) {
            pipelineDescriptor.isAlphaToCoverageEnabled = true
        } else {
            pipelineDescriptor.isAlphaToCoverageEnabled = false
        }
    }
}
