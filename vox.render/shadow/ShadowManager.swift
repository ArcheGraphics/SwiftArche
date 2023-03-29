//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties./

import Metal

public class ShadowManager {
    private static let _shadowSamplerProperty = "u_shadowSampler"
    private static let _shadowTextureProperty = "u_shadowTexture"

    final class ShadowRenderCommandEncoderData: EmptyClassType {
        var depthOutput: Resource<MTLTextureDescriptor>?
        required init() {}
    }
    
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

    public func draw(with commandBuffer: MTLCommandBuffer) {
        _drawDirectShadowMap(with: commandBuffer)
        _drawSpotShadowMap(with: commandBuffer)
        _drawPointShadowMap(with: commandBuffer)
    }

    private func _drawDirectShadowMap(with commandBuffer: MTLCommandBuffer) {
        let fg = Engine.fg
        _cascadedShadowSubpass._updateShadowSettings();
        let descriptor = _cascadedShadowSubpass._getshadowMapDescriptor()
        
        let task = fg.addRenderTask(for: ShadowRenderCommandEncoderData.self, name: "directShadowMap pass") { data, builder in
            data.depthOutput = builder.write(resource: builder.create(name: "direct shadow map", description: descriptor))
        } execute: { [self] builder in
            // setup pipeline state
            let shadowMap = builder.depthOutput!.actual
            let shaderData = Engine.fg.shaderData
            shaderData.setImageView(ShadowManager._shadowTextureProperty,
                    ShadowManager._shadowSamplerProperty, shadowMap)
            shaderData.setSampler(ShadowManager._shadowSamplerProperty, _shadowSampler)
            shaderData.enableMacro(CASCADED_COUNT.rawValue, (_camera.scene.shadowCascades.rawValue, .int))
            
            // render shadow map
            _passDescriptor.depthAttachment.texture = shadowMap
            var encoder = RenderCommandEncoder(commandBuffer, _passDescriptor, "direct shadow pass")
            _cascadedShadowSubpass.draw(pipeline: _camera.devicePipeline, on: &encoder)
            encoder.endEncoding()
        }
        fg.blackboard[BlackBoardType.shadow.rawValue] = task.data.depthOutput
    }

    private func _drawSpotShadowMap(with commandBuffer: MTLCommandBuffer) {
    }

    private func _drawPointShadowMap(with commandBuffer: MTLCommandBuffer) {
    }
}
