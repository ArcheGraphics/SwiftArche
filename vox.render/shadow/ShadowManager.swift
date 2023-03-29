//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties./

import Metal

public class ShadowManager {
    static let _shadowSamplerProperty = "u_shadowSampler"

    private let _camera: Camera
    private let _cascadedShadowSubpass: CascadedShadowSubpass
    private var _descriptor = MTLRenderPassDescriptor()
    private let _shadowSampler = MTLSamplerDescriptor()

    init(_ pipeline: DevicePipeline) {
        _camera = pipeline.camera
        _cascadedShadowSubpass = CascadedShadowSubpass(_camera)

        _shadowSampler.compareFunction = .less
        _shadowSampler.minFilter = .linear
        _shadowSampler.magFilter = .linear
        _shadowSampler.rAddressMode = .clampToEdge
        _shadowSampler.sAddressMode = .clampToEdge
        _shadowSampler.tAddressMode = .clampToEdge
    }

    public func draw(fg: inout FrameGraph, with commandBuffer: MTLCommandBuffer) {
        _camera.scene.shaderData.setSampler(ShadowManager._shadowSamplerProperty, _shadowSampler)
        _drawDirectShadowMap(fg: &fg, with: commandBuffer)
        _drawSpotShadowMap(fg: &fg, with: commandBuffer)
        _drawPointShadowMap(fg: &fg, with: commandBuffer)
    }

    private func _drawDirectShadowMap(fg: inout FrameGraph, with commandBuffer: MTLCommandBuffer) {
        _cascadedShadowSubpass._updateShadowSettings();
        _cascadedShadowSubpass._getAvailableRenderTarget()
        _descriptor.depthAttachment.texture = _cascadedShadowSubpass._depthTexture
        _descriptor.depthAttachment.loadAction = .clear
        _descriptor.depthAttachment.storeAction = .store
        
        let renderContext = RenderCommandEncoderDescriptor(label: "direct light shadow",
                                                           renderTarget: _descriptor,
                                                           commandBuffer: commandBuffer)
        fg.addRenderTask(for: RenderCommandEncoderData.self, name: "directShadowMap pass") { data, builder in
            data.output = builder.write(resource: builder.create(name: "", description: renderContext))
        } execute: { [self] builder in
            if var encoder = builder.output.actual {
                _cascadedShadowSubpass.draw(pipeline: _camera.devicePipeline, on: &encoder)
                encoder.endEncoding()
            }
        }
    }

    private func _drawSpotShadowMap(fg: inout FrameGraph, with commandBuffer: MTLCommandBuffer) {
    }

    private func _drawPointShadowMap(fg: inout FrameGraph, with commandBuffer: MTLCommandBuffer) {
    }
}
