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
    private var _passDescriptor = MTLRenderPassDescriptor()
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
        
        _passDescriptor.depthAttachment.loadAction = .clear
        _passDescriptor.depthAttachment.storeAction = .store
    }

    public func draw(fg: FrameGraph, with commandBuffer: MTLCommandBuffer) {
        _camera.scene.shaderData.setSampler(ShadowManager._shadowSamplerProperty, _shadowSampler)
        _drawDirectShadowMap(fg: fg, with: commandBuffer)
        _drawSpotShadowMap(fg: fg, with: commandBuffer)
        _drawPointShadowMap(fg: fg, with: commandBuffer)
    }

    private func _drawDirectShadowMap(fg: FrameGraph, with commandBuffer: MTLCommandBuffer) {
        _cascadedShadowSubpass._updateShadowSettings();
        let descriptor = _cascadedShadowSubpass._getshadowMapDescriptor()
        
        let task = fg.addRenderTask(for: ShadowRenderCommandEncoderData.self, name: "directShadowMap pass") { data, builder in
            data.depthOutput = builder.write(resource: builder.create(name: "direct shadow map", description: descriptor))
        } execute: { [self] builder in
            _passDescriptor.depthAttachment.texture = builder.depthOutput!.actual
            var encoder = RenderCommandEncoder(commandBuffer, _passDescriptor, "direct shadow pass")
            _cascadedShadowSubpass.draw(pipeline: _camera.devicePipeline, on: &encoder)
            encoder.endEncoding()
        }
        fg.blackboard["shadow"] = task.data.depthOutput
    }

    private func _drawSpotShadowMap(fg: FrameGraph, with commandBuffer: MTLCommandBuffer) {
    }

    private func _drawPointShadowMap(fg: FrameGraph, with commandBuffer: MTLCommandBuffer) {
    }
}

final class ShadowRenderCommandEncoderData: EmptyClassType {
    var depthOutput: Resource<MTLTextureDescriptor>?
    required init() {}
}
