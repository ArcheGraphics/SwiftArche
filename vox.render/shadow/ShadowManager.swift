//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties./

import Metal

public class ShadowManager {
    static let _shadowSamplerProperty = "u_shadowSampler"

    private let _camera: Camera
    private var _renderPass: RenderPass
    private let _cascadedShadowSubpass: CascadedShadowSubpass
    private var _descriptor = MTLRenderPassDescriptor()
    private let _shadowSampler = MTLSamplerDescriptor()

    init(_ pipeline: DevicePipeline) {
        _camera = pipeline.camera
        _cascadedShadowSubpass = CascadedShadowSubpass(_camera)
        _renderPass = RenderPass(pipeline)
        _renderPass.addSubpass(_cascadedShadowSubpass)

        _shadowSampler.compareFunction = .less
        _shadowSampler.minFilter = .linear
        _shadowSampler.magFilter = .linear
        _shadowSampler.rAddressMode = .clampToEdge
        _shadowSampler.sAddressMode = .clampToEdge
        _shadowSampler.tAddressMode = .clampToEdge
    }

    public func draw(_ commandBuffer: MTLCommandBuffer) {
        _camera.scene.shaderData.setSampler(ShadowManager._shadowSamplerProperty, _shadowSampler)
        _drawDirectShadowMap(commandBuffer)
        _drawSpotShadowMap(commandBuffer)
        _drawPointShadowMap(commandBuffer)
    }

    private func _drawDirectShadowMap(_ commandBuffer: MTLCommandBuffer) {
        _cascadedShadowSubpass._updateShadowSettings();
        _cascadedShadowSubpass._getAvailableRenderTarget()
        _descriptor.depthAttachment.texture = _cascadedShadowSubpass._depthTexture
        _descriptor.depthAttachment.loadAction = .clear
        _descriptor.depthAttachment.storeAction = .store
        _renderPass.draw(commandBuffer, _descriptor)
    }

    private func _drawSpotShadowMap(_ commandBuffer: MTLCommandBuffer) {
    }

    private func _drawPointShadowMap(_ commandBuffer: MTLCommandBuffer) {
    }
}
