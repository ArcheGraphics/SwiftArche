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

    func draw(with commandBuffer: MTLCommandBuffer) {
        _drawDirectShadowMap(with: commandBuffer)
        _drawSpotShadowMap(with: commandBuffer)
        _drawPointShadowMap(with: commandBuffer)
    }

    private func _drawDirectShadowMap(with commandBuffer: MTLCommandBuffer) {
        let fg = Engine.fg
        _cascadedShadowSubpass._updateShadowSettings()
        let mapDesc = _cascadedShadowSubpass._descriptor

        let task = fg.addFrameTask(for: ShadowRenderCommandEncoderData.self, name: "directShadowMap pass",
                                   commandBuffer: commandBuffer)
        { data, builder in
            data.depthOutput = builder.write(resource: builder.create(name: "direct shadow map", description: mapDesc))
        } execute: { [self] builder, commandBuffer in
            if let commandBuffer {
                // setup pipeline state
                let shadowMap = builder.depthOutput!.actual
                let frameData = Engine.fg.frameData
                frameData.setImageView(ShadowManager._shadowTextureProperty,
                                       ShadowManager._shadowSamplerProperty, shadowMap)
                frameData.setSampler(ShadowManager._shadowSamplerProperty, _shadowSampler)
                frameData.enableMacro(CASCADED_COUNT.rawValue, (_camera.scene.shadowCascades.rawValue, .int))

                // render shadow map
                _camera.devicePipeline.context.pipelineStageTagValue = PipelineStage.ShadowCaster
                _cascadedShadowSubpass._shadowTexture = shadowMap
                _cascadedShadowSubpass.renderShadows(to: commandBuffer)
            }
        }
        fg.blackboard[BlackBoardType.shadow.rawValue] = task.data.depthOutput
    }

    private func _drawSpotShadowMap(with _: MTLCommandBuffer) {}

    private func _drawPointShadowMap(with _: MTLCommandBuffer) {}
}
