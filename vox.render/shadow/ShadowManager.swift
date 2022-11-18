//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties./

import Metal

public class ShadowManager {
    private let _camera: Camera
    private var _renderPass: RenderPass
    private let _cascadedShadowSubpass: CascadedShadowSubpass
    private var _descriptor = MTLRenderPassDescriptor()
    private var _depthTexture: MTLTexture!
    private let _shadowTextureProperty = "u_shadowTexture"
    private let _shadowSamplerProperty = "u_shadowSampler"

    init(_ pipeline: DevicePipeline) {
        _camera = pipeline.camera
        _cascadedShadowSubpass = CascadedShadowSubpass(_camera)
        _renderPass = RenderPass(pipeline)
        _renderPass.addSubpass(_cascadedShadowSubpass)
    }

    public func draw(_ commandBuffer: MTLCommandBuffer) {
        _drawDirectShadowMap(commandBuffer)
        _drawSpotShadowMap(commandBuffer)
        _drawPointShadowMap(commandBuffer)
    }

    private func _drawDirectShadowMap(_ commandBuffer: MTLCommandBuffer) {
        _cascadedShadowSubpass._updateShadowSettings();
        _getAvailableRenderTarget()
        _descriptor.depthAttachment.texture = _depthTexture

        _renderPass.draw(commandBuffer, _descriptor)
        _camera.scene.shaderData.setImageView(_shadowTextureProperty, _shadowSamplerProperty, _depthTexture)
    }

    private func _drawSpotShadowMap(_ commandBuffer: MTLCommandBuffer) {
    }

    private func _drawPointShadowMap(_ commandBuffer: MTLCommandBuffer) {
    }

    private func _getAvailableRenderTarget() {
    }
}