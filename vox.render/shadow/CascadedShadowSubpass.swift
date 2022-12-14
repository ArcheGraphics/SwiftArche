//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math
import Metal
import simd

class CascadedShadowSubpass: GeometrySubpass {
    private static let _lightViewProjMatProperty = "u_lightViewProjMat"
    private static let _lightShadowBiasProperty = "u_shadowBias"
    private static let _lightDirectionProperty = "u_lightDirection"

    private static let _shadowMatricesProperty = "u_shadowMatrices"
    private static let _shadowMapSize = "u_shadowMapSize"
    private static let _shadowInfosProperty = "u_shadowInfo"
    private static let _shadowTextureProperty = "u_shadowTexture"
    private static let _shadowSplitSpheresProperty = "u_shadowSplitSpheres"

    private static var _maxCascades: Int = 4
    private static var _cascadesSplitDistance: [Float] = [Float](repeating: 0, count: CascadedShadowSubpass._maxCascades + 1)

    private let _camera: Camera
    private var _shaderPass: ShaderPass

    private var _shadowMapResolution: UInt32 = 0
    private var _shadowMapSize: Vector4 = Vector4()
    private var _shadowTileResolution: UInt32 = 0
    private var _shadowMapFormat: MTLPixelFormat = .invalid
    private var _shadowCascadeMode: ShadowCascadesMode = .NoCascades
    private var _shadowSliceData: ShadowSliceData = ShadowSliceData()
    private var _existShadowMap: Bool = false

    private var _splitBoundSpheres = [Float](repeating: 0, count: 4 * CascadedShadowSubpass._maxCascades)
    /** The end is project precision problem in shader. */
    private var _shadowMatrices = [simd_float4x4](repeating: simd_float4x4(), count: CascadedShadowSubpass._maxCascades + 1)
    // strength, null, lightIndex
    private var _shadowInfos = SIMD3<Float>()
    var _depthTexture: MTLTexture!
    private var _viewportOffsets: [Vector2] = [Vector2](repeatElement(Vector2(), count: 4))

    init(_ camera: Camera) {
        _camera = camera
        _shaderPass = ShaderPass(camera.engine.library(), "vertex_shadowmap", nil)
        _shadowSliceData.virtualCamera.isOrthographic = true
        super.init()
    }

    override func prepare(_ pipelineDescriptor: MTLRenderPipelineDescriptor, _ depthStencilDescriptor: MTLDepthStencilDescriptor) {
        pipelineDescriptor.label = "shadow map"
        pipelineDescriptor.depthAttachmentPixelFormat = _shadowMapFormat
    }

    override func drawElement(_ encoder: inout RenderCommandEncoder) {
        _existShadowMap = false
        _renderDirectShadowMap(&encoder)

        if (_existShadowMap) {
            _updateReceiversShaderData()
            _camera.scene.shaderData.setImageView(CascadedShadowSubpass._shadowTextureProperty,
                    ShadowManager._shadowSamplerProperty, _depthTexture)
        } else {
            _camera.scene.shaderData.setImageView(CascadedShadowSubpass._shadowTextureProperty,
                    ShadowManager._shadowSamplerProperty, nil)
        }
    }

    func _updateShadowSettings() {
        let scene = _camera.scene
        let shadowFormat = ShadowUtils.shadowDepthFormat(scene.shadowResolution)
        let shadowResolution = ShadowUtils.shadowResolution(scene.shadowResolution)
        let shadowCascades = scene.shadowCascades

        if (shadowFormat != _shadowMapFormat ||
                shadowResolution != _shadowMapResolution ||
                shadowCascades != _shadowCascadeMode) {
            _shadowMapFormat = shadowFormat
            _shadowMapResolution = shadowResolution
            _shadowCascadeMode = shadowCascades

            if (shadowCascades == ShadowCascadesMode.NoCascades) {
                _shadowTileResolution = shadowResolution
                _shadowMapSize = Vector4(1 / Float(shadowResolution), 1 / Float(shadowResolution), Float(shadowResolution), Float(shadowResolution))
            } else {
                let shadowTileResolution = ShadowUtils.getMaxTileResolutionInAtlas(
                        atlasWidth: shadowResolution,
                        atlasHeight: shadowResolution,
                        tileCount: shadowCascades.rawValue
                )
                _shadowTileResolution = shadowTileResolution
                let width = Float(shadowTileResolution * 2)
                let height = shadowCascades == ShadowCascadesMode.TwoCascades ? Float(shadowTileResolution) : Float(shadowTileResolution * 2)
                _shadowMapSize = Vector4(1.0 / width, 1.0 / height, width, height)
            }

            switch (shadowCascades) {
            case ShadowCascadesMode.NoCascades:
                _viewportOffsets[0] = Vector2()
                break
            case ShadowCascadesMode.TwoCascades:
                _viewportOffsets[0] = Vector2(0, 0)
                _viewportOffsets[1] = Vector2(Float(_shadowTileResolution), 0)
                break
            case ShadowCascadesMode.FourCascades:
                _viewportOffsets[0] = Vector2(0, 0)
                _viewportOffsets[1] = Vector2(Float(_shadowTileResolution), 0)
                _viewportOffsets[2] = Vector2(0, Float(_shadowTileResolution))
                _viewportOffsets[3] = Vector2(Float(_shadowTileResolution), Float(_shadowTileResolution))
            }
        }
    }

    private func _renderDirectShadowMap(_ encoder: inout RenderCommandEncoder) {
        let shadowCascades = _camera.scene.shadowCascades.rawValue
        let bufferBlock = _camera.engine.requestBufferBlock(minimum_size: 4 * 256)

        let sunLightIndex = _camera.engine._lightManager._getSunLightIndex()
        if sunLightIndex != -1,
           let light = _camera.scene._sunLight {
            let shadowFar = min(_camera.scene.shadowDistance, _camera.farClipPlane)
            _getCascadesSplitDistance(shadowFar)
            _shadowInfos.x = light.shadowStrength
            _shadowInfos.z = Float(sunLightIndex)

            // prepare light and camera direction
            let lightWorld = Matrix.rotationQuaternion(quaternion: light.entity.transform.worldRotationQuaternion)
            let lightSide = Vector3(lightWorld.elements.columns.0[0], lightWorld.elements.columns.0[1], lightWorld.elements.columns.0[2])
            let lightUp = Vector3(lightWorld.elements.columns.1[0], lightWorld.elements.columns.1[1], lightWorld.elements.columns.1[2])
            let lightForward = Vector3(-lightWorld.elements.columns.2[0], -lightWorld.elements.columns.2[1], -lightWorld.elements.columns.2[2])
            var cameraWorldForward = _camera.entity.transform.worldForward
            _shadowSliceData.virtualCamera.forward = lightForward

            for j in 0..<shadowCascades {
                ShadowUtils.getBoundSphereByFrustum(
                        near: CascadedShadowSubpass._cascadesSplitDistance[j],
                        far: CascadedShadowSubpass._cascadesSplitDistance[j + 1],
                        camera: _camera,
                        forward: cameraWorldForward.normalize(),
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
                        shadowResolution: _shadowTileResolution,
                        shadowSliceData: _shadowSliceData,
                        outShadowMatrices: &_shadowMatrices
                )
                if (shadowCascades > 1) {
                    ShadowUtils.applySliceTransform(
                            tileSize: _shadowTileResolution,
                            atlasWidth: Int(_shadowMapSize.z),
                            atlasHeight: Int(_shadowMapSize.w),
                            cascadeIndex: j,
                            atlasOffset: _viewportOffsets[j],
                            outShadowMatrices: &_shadowMatrices
                    )
                }
                _updateSingleShadowCasterShaderData(&encoder, bufferBlock, (light as! DirectLight), _shadowSliceData)

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
                let renderers = _camera.engine._componentsManager._renderers
                let elements = renderers._elements
                for k in 0..<renderers.count {
                    ShadowUtils.shadowCullFrustum(_shadowSliceData.virtualCamera, pipeline, _camera, light, elements[k]!, _shadowSliceData)
                }
                pipeline._opaqueQueue.sort(by: DevicePipeline._compareFromNearToFar)
                pipeline._alphaTestQueue.sort(by: DevicePipeline._compareFromNearToFar)

                encoder.handle.setViewport(MTLViewport(originX: Double(_viewportOffsets[j].x), originY: Double(_viewportOffsets[j].y),
                        width: Double(_shadowTileResolution), height: Double(_shadowTileResolution), znear: 0, zfar: 1))
                // for no cascade is for the edge,for cascade is for the beyond maxCascade pixel can use (0,0,0) trick sample the shadowMap
                encoder.handle.setScissorRect(MTLScissorRect(x: Int(_viewportOffsets[j].x + 1), y: Int(_viewportOffsets[j].y + 1),
                        width: Int(_shadowTileResolution - 2), height: Int(_shadowTileResolution - 2)))
                for i in 0..<pipeline._opaqueQueue.count {
                    pipeline._opaqueQueue[i].shaderPass = _shaderPass
                    super._drawElement(&encoder, pipeline._opaqueQueue[i])
                }

                for i in 0..<pipeline._alphaTestQueue.count {
                    pipeline._alphaTestQueue[i].shaderPass = _shaderPass
                    super._drawElement(&encoder, pipeline._alphaTestQueue[i])
                }
            }
            _existShadowMap = true
        }
    }

    private func _getCascadesSplitDistance(_ shadowFar: Float) {
        let shadowTwoCascadeSplits = _camera.scene.shadowTwoCascadeSplits
        let shadowFourCascadeSplits = _camera.scene.shadowFourCascadeSplits
        let shadowCascades = _camera.scene.shadowCascades
        let nearClipPlane = _camera.nearClipPlane
        let aspectRatio = _camera.aspectRatio
        let fieldOfView = _camera.fieldOfView

        CascadedShadowSubpass._cascadesSplitDistance[0] = nearClipPlane
        let range = shadowFar - nearClipPlane
        let tFov = tan(MathUtil.degreeToRadian(fieldOfView) * 0.5)
        let denominator = 1.0 + tFov * tFov * (aspectRatio * aspectRatio + 1.0)
        switch (shadowCascades) {
        case ShadowCascadesMode.NoCascades:
            CascadedShadowSubpass._cascadesSplitDistance[1] = _getFarWithRadius(shadowFar, denominator)
            break
        case ShadowCascadesMode.TwoCascades:
            CascadedShadowSubpass._cascadesSplitDistance[1] = _getFarWithRadius(nearClipPlane + range * shadowTwoCascadeSplits, denominator)
            CascadedShadowSubpass._cascadesSplitDistance[2] = _getFarWithRadius(shadowFar, denominator)
            break
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
            break
        }
    }

    private func _getFarWithRadius(_ radius: Float, _ denominator: Float) -> Float {
        // use the frustum side as the radius and get the far distance form camera.
        // var tFov: number = Math.tan(fov * 0.5)// get this the equation using Pythagorean
        // return Math.sqrt(radius * radius / (1.0 + tFov * tFov * (aspectRatio * aspectRatio + 1.0)))
        sqrt((radius * radius) / denominator)
    }

    private func _updateReceiversShaderData() {
        let scene = _camera.scene
        let shadowCascades = scene.shadowCascades.rawValue
        if shadowCascades > 1 {
            for i in (shadowCascades * 4)..<_splitBoundSpheres.count {
                _splitBoundSpheres[i] = 0.0
            }
        }

        // set zero matrix to project the index out of max cascade
        for i in shadowCascades..<_shadowMatrices.count {
            _shadowMatrices[i] = simd_float4x4()
        }

        let shaderData = scene.shaderData
        shaderData.setDynamicData(CascadedShadowSubpass._shadowMatricesProperty, _shadowMatrices)
        shaderData.setDynamicData(CascadedShadowSubpass._shadowInfosProperty, _shadowInfos)
        shaderData.setDynamicData(CascadedShadowSubpass._shadowSplitSpheresProperty, _splitBoundSpheres)
        shaderData.setDynamicData(CascadedShadowSubpass._shadowMapSize, _shadowMapSize)
    }

    private func _updateSingleShadowCasterShaderData(_ encoder: inout RenderCommandEncoder, _ bufferBlock: BufferBlock,
                                                     _ light: DirectLight, _ shadowSliceData: ShadowSliceData) {
        let virtualCamera = shadowSliceData.virtualCamera
        let shadowBias = ShadowUtils.getShadowBias(light: light, projectionMatrix: virtualCamera.projectionMatrix, shadowResolution: _shadowTileResolution)

        let shaderData = _camera.scene.shaderData
        shaderData.setDynamicData(CascadedShadowSubpass._lightShadowBiasProperty, shadowBias)
        shaderData.setDynamicData(CascadedShadowSubpass._lightDirectionProperty, light.direction)

        let allocation = bufferBlock.allocate(MemoryLayout<Matrix>.size)!
        allocation.update(shadowSliceData.virtualCamera.viewProjectionMatrix)
        encoder.handle.setVertexBuffer(allocation.buffer, offset: allocation.offset, index: 3)
    }

    func _getAvailableRenderTarget() {
        if (_depthTexture == nil ||
                _depthTexture.width != Int(_shadowMapSize.z) ||
                _depthTexture.height != Int(_shadowMapSize.w) ||
                _depthTexture.pixelFormat != _shadowMapFormat) {
            let descriptor = MTLTextureDescriptor()
            descriptor.width = Int(_shadowMapSize.z)
            descriptor.height = Int(_shadowMapSize.w)
            descriptor.pixelFormat = _shadowMapFormat
            descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
            descriptor.storageMode = .private
            _depthTexture = _camera.engine.device.makeTexture(descriptor: descriptor)
        }
    }
}
