//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal
import simd

class CascadedShadowSubpass: GeometrySubpass {
    private static let _lightViewProjMatProperty = "u_lightViewProjMat"

    private static let _shadowMatricesProperty = "u_shadowMatrices"
    private static let _shadowMapSize = "u_shadowMapSize"
    private static let _shadowInfosProperty = "u_shadowInfo"
    private static let _shadowSplitSpheresProperty = "u_shadowSplitSpheres"

    private static var _maxCascades: Int = 4
    private static var _cascadesSplitDistance: [Float] = .init(repeating: 0, count: CascadedShadowSubpass._maxCascades + 1)

    private let _camera: Camera

    private var _shadowMapResolution: UInt32 = 0
    private var _shadowMapSize: Vector4 = .init()
    private var _shadowMapFormat: MTLPixelFormat = .invalid
    private var _shadowCascadeMode: ShadowCascadesMode = .NoCascades
    private var _shadowSliceData: ShadowSliceData = .init()
    private var _existShadowMap: Bool = false

    private var _splitBoundSpheres = [Float](repeating: 0, count: 4 * CascadedShadowSubpass._maxCascades)
    /** The end is project precision problem in shader. */
    private var _shadowMatrices = [simd_float4x4](repeating: simd_float4x4(), count: CascadedShadowSubpass._maxCascades + 1)
    // strength, null, lightIndex
    private var _shadowInfos = SIMD3<Float>()
    var _descriptor = MTLTextureDescriptor()

    private var _shadowPassDescriptor = MTLRenderPassDescriptor()
    var _shadowTexture: MTLTexture!

    init(_ camera: Camera) {
        _camera = camera
        _shadowSliceData.virtualCamera.isOrthographic = true
        super.init()

        _descriptor.usage = [.renderTarget, .shaderRead]
        _descriptor.storageMode = .private
        _descriptor.textureType = .type2DArray

        _shadowPassDescriptor.depthAttachment.slice = 0
        _shadowPassDescriptor.depthAttachment.clearDepth = 1.0
        _shadowPassDescriptor.depthAttachment.loadAction = .clear
        _shadowPassDescriptor.depthAttachment.storeAction = .store
    }

    override func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor, _: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "shadow map"
        pipelineDescriptor.depthAttachmentPixelFormat = _shadowMapFormat
        if RenderConfig.useSinglePassCSMGeneration {
            // Enable vertex amplification - need a minimum of 2 amplification to enable on shaders
            pipelineDescriptor.maxVertexAmplificationCount = 2
        } else {
            pipelineDescriptor.maxVertexAmplificationCount = 1
        }
    }

    /// Encapsulates the different ways of rendering the shadow.
    func renderShadows(to commandBuffer: MTLCommandBuffer) {
        _existShadowMap = false
        _renderDirectShadowMap(to: commandBuffer)

        if _existShadowMap {
            _updateReceiversShaderData(with: Engine.requestBufferBlock(minimum_size: 5 * 256))
        }
    }

    private func _renderDirectShadowMap(to commandBuffer: MTLCommandBuffer) {
        let shadowCascades = _shadowCascadeMode.rawValue
        let bufferBlock = Engine.requestBufferBlock(minimum_size: 10 * 256)
        _shadowPassDescriptor.depthAttachment.texture = _shadowTexture

        let sunLightIndex = Engine._lightManager._getSunLightIndex()
        if sunLightIndex != -1,
           let light = _camera.scene._sunLight
        {
            let shadowFar = min(_camera.scene.shadowDistance, _camera.farClipPlane)
            _getCascadesSplitDistance(shadowFar)
            _shadowInfos.x = light.shadowStrength
            _shadowInfos.z = Float(sunLightIndex)

            // prepare light and camera direction
            let lightWorld = Matrix.rotationQuaternion(quaternion: light.entity.transform.worldRotationQuaternion)
            let lightSide = Vector3(lightWorld.elements.columns.0[0], lightWorld.elements.columns.0[1], lightWorld.elements.columns.0[2])
            let lightUp = Vector3(lightWorld.elements.columns.1[0], lightWorld.elements.columns.1[1], lightWorld.elements.columns.1[2])
            let lightForward = Vector3(-lightWorld.elements.columns.2[0], -lightWorld.elements.columns.2[1], -lightWorld.elements.columns.2[2])
            let cameraWorldForward = _camera.entity.transform.worldForward.normalized
            _shadowSliceData.virtualCamera.forward = lightForward

            var encoder: RenderCommandEncoder!
            if RenderConfig.useSinglePassCSMGeneration {
                _shadowPassDescriptor.depthAttachment.slice = 0
                _shadowPassDescriptor.renderTargetArrayLength = shadowCascades
                encoder = RenderCommandEncoder(commandBuffer, _shadowPassDescriptor, "direct shadow pass")
                encoder.handle.label = "Shadow Cascade Layered"
                encoder.handle.setDepthBias(0, slopeScale: 2, clamp: 0)
            }

            for j in 0 ..< shadowCascades {
                if RenderConfig.useSinglePassCSMGeneration {
                    var viewMapping = MTLVertexAmplificationViewMapping(viewportArrayIndexOffset: 0, renderTargetArrayIndexOffset: UInt32(j))
                    encoder.handle.setVertexAmplificationCount(1, viewMappings: &viewMapping)
                    encoder._uploadFrameGraph = nil // flush manually
                } else {
                    _shadowPassDescriptor.depthAttachment.slice = j
                    encoder = RenderCommandEncoder(commandBuffer, _shadowPassDescriptor, "direct shadow pass")
                    encoder.handle.label = "Shadow Cascade \(j)"
                    encoder.handle.setDepthBias(0, slopeScale: 2, clamp: 0)
                }

                ShadowUtils.getBoundSphereByFrustum(
                    near: CascadedShadowSubpass._cascadesSplitDistance[j],
                    far: CascadedShadowSubpass._cascadesSplitDistance[j + 1],
                    camera: _camera,
                    forward: cameraWorldForward,
                    shadowSliceData: _shadowSliceData
                )
                ShadowUtils.getDirectionLightShadowCullPlanes(
                    cameraFrustum: _camera._frustum,
                    splitDistance: CascadedShadowSubpass._cascadesSplitDistance[j],
                    cameraNear: _camera.nearClipPlane,
                    direction: lightForward,
                    shadowSliceData: _shadowSliceData
                )
                ShadowUtils.getDirectionalLightMatrices(
                    lightUp: lightUp,
                    lightSide: lightSide,
                    lightForward: lightForward,
                    cascadeIndex: j,
                    nearPlane: light.shadowNearPlane,
                    shadowResolution: _shadowMapResolution,
                    shadowSliceData: _shadowSliceData,
                    outShadowMatrices: &_shadowMatrices
                )
                _updateSingleShadowCasterShaderData(bufferBlock, _shadowSliceData)

                // upload pre-cascade infos.
                let center = _shadowSliceData.splitBoundSphere.center
                let radius = _shadowSliceData.splitBoundSphere.radius
                let offset = j * 4
                _splitBoundSpheres[offset] = center.x
                _splitBoundSpheres[offset + 1] = center.y
                _splitBoundSpheres[offset + 2] = center.z
                _splitBoundSpheres[offset + 3] = radius * radius

                let pipeline = _camera.devicePipeline!
                pipeline._opaqueQueue.removeAll()
                pipeline._alphaTestQueue.removeAll()
                pipeline._transparentQueue.removeAll()
                let renderers = Engine._componentsManager._renderers
                let elements = renderers._elements
                for k in 0 ..< renderers.count {
                    ShadowUtils.shadowCullFrustum(_shadowSliceData.virtualCamera, pipeline, _camera, light, elements[k]!, _shadowSliceData)
                }
                pipeline._opaqueQueue.sort(by: DevicePipeline._compareFromNearToFar)
                pipeline._alphaTestQueue.sort(by: DevicePipeline._compareFromNearToFar)

                for i in 0 ..< pipeline._opaqueQueue.count {
                    super._drawElement(pipeline: pipeline, on: &encoder, pipeline._opaqueQueue[i])
                }

                for i in 0 ..< pipeline._alphaTestQueue.count {
                    super._drawElement(pipeline: pipeline, on: &encoder, pipeline._alphaTestQueue[i])
                }

                if !RenderConfig.useSinglePassCSMGeneration {
                    encoder.endEncoding()
                }
            }

            if RenderConfig.useSinglePassCSMGeneration {
                encoder.endEncoding()
            }
            _existShadowMap = true
        }
    }

    private func _getCascadesSplitDistance(_ shadowFar: Float) {
        let shadowTwoCascadeSplits = _camera.scene.shadowTwoCascadeSplits
        let shadowFourCascadeSplits = _camera.scene.shadowFourCascadeSplits
        let nearClipPlane = _camera.nearClipPlane
        let aspectRatio = _camera.aspectRatio
        let fieldOfView = _camera.fieldOfView

        CascadedShadowSubpass._cascadesSplitDistance[0] = nearClipPlane
        let range = shadowFar - nearClipPlane
        let tFov = tan(MathUtil.degreeToRadian(fieldOfView) * 0.5)
        let denominator = 1.0 + tFov * tFov * (aspectRatio * aspectRatio + 1.0)
        switch _shadowCascadeMode {
        case ShadowCascadesMode.NoCascades:
            CascadedShadowSubpass._cascadesSplitDistance[1] = _getFarWithRadius(shadowFar, denominator)
        case ShadowCascadesMode.TwoCascades:
            CascadedShadowSubpass._cascadesSplitDistance[1] = _getFarWithRadius(nearClipPlane + range * shadowTwoCascadeSplits, denominator)
            CascadedShadowSubpass._cascadesSplitDistance[2] = _getFarWithRadius(shadowFar, denominator)
        case ShadowCascadesMode.FourCascades:
            CascadedShadowSubpass._cascadesSplitDistance[1] = _getFarWithRadius(
                nearClipPlane + range * shadowFourCascadeSplits.x,
                denominator
            )
            CascadedShadowSubpass._cascadesSplitDistance[2] = _getFarWithRadius(
                nearClipPlane + range * shadowFourCascadeSplits.y,
                denominator
            )
            CascadedShadowSubpass._cascadesSplitDistance[3] = _getFarWithRadius(
                nearClipPlane + range * shadowFourCascadeSplits.z,
                denominator
            )
            CascadedShadowSubpass._cascadesSplitDistance[4] = _getFarWithRadius(shadowFar, denominator)
        }
    }

    private func _getFarWithRadius(_ radius: Float, _ denominator: Float) -> Float {
        // use the frustum side as the radius and get the far distance form camera.
        // var tFov: number = Math.tan(fov * 0.5)// get this the equation using Pythagorean
        // return Math.sqrt(radius * radius / (1.0 + tFov * tFov * (aspectRatio * aspectRatio + 1.0)))
        sqrt((radius * radius) / denominator)
    }

    private func _updateSingleShadowCasterShaderData(_ bufferBlock: BufferBlock, _ shadowSliceData: ShadowSliceData)
    {
        let frameData = Engine.fg.frameData
        let allocation = bufferBlock.allocate(MemoryLayout<Matrix>.stride)
        allocation.update(shadowSliceData.virtualCamera.viewProjectionMatrix)
        frameData.setData(CascadedShadowSubpass._lightViewProjMatProperty, allocation)
    }

    private func _updateReceiversShaderData(with bufferBlock: BufferBlock) {
        let shadowCascades = _shadowCascadeMode.rawValue
        if shadowCascades > 1 {
            for i in (shadowCascades * 4) ..< _splitBoundSpheres.count {
                _splitBoundSpheres[i] = 0.0
            }
        }

        // set zero matrix to project the index out of max cascade
        for i in shadowCascades ..< _shadowMatrices.count {
            _shadowMatrices[i] = simd_float4x4(1)
        }

        let frameData = Engine.fg.frameData
        var allocation = bufferBlock.allocate(MemoryLayout<simd_float4x4>.stride * _shadowMatrices.count)
        allocation.update(_shadowMatrices)
        frameData.setData(CascadedShadowSubpass._shadowMatricesProperty, allocation)

        allocation = bufferBlock.allocate(MemoryLayout<SIMD3<Float>>.stride)
        allocation.update(_shadowInfos)
        frameData.setData(CascadedShadowSubpass._shadowInfosProperty, allocation)

        allocation = bufferBlock.allocate(MemoryLayout<Float>.stride * _splitBoundSpheres.count)
        allocation.update(_splitBoundSpheres)
        frameData.setData(CascadedShadowSubpass._shadowSplitSpheresProperty, allocation)

        allocation = bufferBlock.allocate(MemoryLayout<Vector4>.stride)
        allocation.update(_shadowMapSize)
        frameData.setData(CascadedShadowSubpass._shadowMapSize, allocation)
    }

    func _updateShadowSettings() {
        let scene = _camera.scene
        let shadowFormat = ShadowUtils.shadowDepthFormat(scene.shadowResolution)
        let shadowResolution = ShadowUtils.shadowResolution(scene.shadowResolution)
        let shadowCascades = scene.shadowCascades

        if shadowFormat != _shadowMapFormat ||
            shadowResolution != _shadowMapResolution ||
            shadowCascades != _shadowCascadeMode
        {
            _shadowMapFormat = shadowFormat
            _shadowMapResolution = shadowResolution
            _shadowCascadeMode = shadowCascades
            _shadowMapSize = Vector4(1 / Float(shadowResolution), 1 / Float(shadowResolution),
                                     Float(shadowResolution), Float(shadowResolution))

            _descriptor.width = Int(_shadowMapSize.z)
            _descriptor.height = Int(_shadowMapSize.w)
            _descriptor.pixelFormat = _shadowMapFormat
            _descriptor.arrayLength = shadowCascades.rawValue
        }
    }
}
