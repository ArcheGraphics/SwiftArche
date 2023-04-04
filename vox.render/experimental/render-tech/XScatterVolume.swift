//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// Encapsulates the pipeline states and intermediate objects for generating a
///  volume of scattered lighting information.
class XScatterVolume {
    /// Device from initialization.
    private var _device: MTLDevice
    /// Pipeline state for updating scattering from the previous frame.
    private var _scatteringPipelineState: MTLComputePipelineState!
    private var _scatteringCLPipelineState: MTLComputePipelineState!

    /// Pipeline state to accumulate the current scattering state into the volume texture.
    private var _scatteringAccumPipelineState: MTLComputePipelineState!
    /// Double buffered scattering volume storage.
    private var _scatteringVolume: [MTLTexture?] = [nil, nil]
    private var _scatteringVolumeIndex: Int = 0
    private var _lightCullingTileSize: Int
    private var _lightClusteringTileSize: Int

    /// The resulting volume data from the last update.
    public private(set) var scatteringAccumVolume: MTLTexture?

    // User specified noise texture for updates.
    var noiseTexture: MTLTexture?
    var perlinNoiseTexture: MTLTexture?

    /// Initializes this object, allocating metal objects from the device based on
    ///  functions in the library.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int)
    {
        _lightCullingTileSize = lightCullingTileSize
        _lightClusteringTileSize = lightClusteringTileSize

        _device = device

        rebuildPipelines(with: library, useRasterizationRate: useRasterizationRate)
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool)
    {
        var TRUE_VALUE = true
        var FALSE_VALUE = false

        let fc = MTLFunctionConstantValues()

        var useRasterizationRate = useRasterizationRate
        fc.setConstantValue(&FALSE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        fc.setConstantValue(&_lightCullingTileSize, type: .uint, index: Int(XFunctionConstIndexLightCullingTileSize.rawValue))
        fc.setConstantValue(&_lightClusteringTileSize, type: .uint, index: Int(XFunctionConstIndexLightClusteringTileSize.rawValue))
        _scatteringPipelineState = newComputePipelineState(library: library, functionName: "kernelScattering",
                                                           label: "ScatteringKernal", functionConstants: fc)

        fc.setConstantValue(&TRUE_VALUE, type: .bool, index: Int(XFunctionConstIndexLightCluster.rawValue))

        _scatteringCLPipelineState = newComputePipelineState(library: library, functionName: "kernelScattering",
                                                             label: "ClusteredScatteringKernal", functionConstants: fc)

        _scatteringAccumPipelineState = newComputePipelineState(library: library, functionName: "kernelAccumulateScattering",
                                                                label: "AccumulateScatteringKernal", functionConstants: nil)
    }

    /// Writes commands to update the volume using the command buffer.
    /// Applies temporal updates which can be reset with the resetHistory flag.
    func update(commandBuffer: MTLCommandBuffer,
                frameDataBuffer: MTLBuffer,
                cameraParamsBuffer: MTLBuffer,
                shadowMap: MTLTexture,
                pointLightBuffer: MTLBuffer,
                spotLightBuffer: MTLBuffer,
                pointLightIndices: MTLBuffer,
                spotLightIndices: MTLBuffer,
                spotLightShadows: MTLTexture,
                rrMapData: MTLBuffer,
                clustered: Bool,
                resetHistory: Bool)
    {
        _scatteringVolumeIndex = 1 - _scatteringVolumeIndex

        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            computeEncoder.label = "ScatteringEncoder"

            computeEncoder.setBuffer(frameDataBuffer, offset: 0, index: Int(XBufferIndexFrameData.rawValue))
            computeEncoder.setBuffer(cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))
            computeEncoder.setBuffer(rrMapData, offset: 0, index: Int(XBufferIndexRasterizationRateMap.rawValue))

            if clustered {
                computeEncoder.setComputePipelineState(_scatteringCLPipelineState)
            } else {
                computeEncoder.setComputePipelineState(_scatteringPipelineState)
            }

            computeEncoder.setBuffer(pointLightBuffer, offset: 0, index: Int(XBufferIndexPointLights.rawValue))
            computeEncoder.setBuffer(spotLightBuffer, offset: 0, index: Int(XBufferIndexSpotLights.rawValue))
            computeEncoder.setBuffer(pointLightIndices, offset: 0, index: Int(XBufferIndexPointLightIndices.rawValue))
            computeEncoder.setBuffer(spotLightIndices, offset: 0, index: Int(XBufferIndexSpotLightIndices.rawValue))
            computeEncoder.setTexture(spotLightShadows, index: 5)
            computeEncoder.setTexture(_scatteringVolume[_scatteringVolumeIndex], index: 0)

            if resetHistory {
                computeEncoder.setTexture(nil, index: 1)
            } else {
                computeEncoder.setTexture(_scatteringVolume[1 - _scatteringVolumeIndex], index: 1)
            }

            computeEncoder.setTexture(noiseTexture, index: 2)
            computeEncoder.setTexture(perlinNoiseTexture, index: 3)
            computeEncoder.setTexture(shadowMap, index: 4)

            if let scatteringVolume = _scatteringVolume[0] {
                // MTLSize groupSize     = {1, 1, SCATTERING_VOLUME_DEPTH}
                var groupSize = MTLSize(width: 4, height: 4, depth: 4)
                var threadGroups = divideRoundUp(numerator: MTLSize(width: scatteringVolume.width,
                                                                    height: scatteringVolume.height,
                                                                    depth: scatteringVolume.depth), denominator: groupSize)

                computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: groupSize)

                computeEncoder.setComputePipelineState(_scatteringAccumPipelineState)
                computeEncoder.setTexture(scatteringAccumVolume, index: 0)
                computeEncoder.setTexture(_scatteringVolume[_scatteringVolumeIndex], index: 1)

                groupSize = MTLSize(width: Int(SCATTERING_TILE_SIZE), height: Int(SCATTERING_TILE_SIZE), depth: 1)
                threadGroups = divideRoundUp(numerator: MTLSize(width: scatteringVolume.width,
                                                                height: scatteringVolume.height, depth: 1), denominator: groupSize)

                computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: groupSize)
            }
            computeEncoder.endEncoding()
        }
    }

    /// Resizes the internal data structures to the required output size.
    func resize(_ size: CGSize) {
        let scatteringVolumeSize = divideRoundUp(
            numerator: MTLSize(width: Int(size.width), height: Int(size.height), depth: 1),
            denominator: MTLSize(width: Int(SCATTERING_TILE_SIZE), height: Int(SCATTERING_TILE_SIZE), depth: 1)
        )

        let validScatteringVolume = _scatteringVolume[0] != nil &&
            (_scatteringVolume[0]!.width == Int(scatteringVolumeSize.width)) &&
            (_scatteringVolume[0]!.height == Int(scatteringVolumeSize.height))

        if !validScatteringVolume {
            let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float,
                                                                width: scatteringVolumeSize.width,
                                                                height: scatteringVolumeSize.height,
                                                                mipmapped: false)

            desc.textureType = .type3D
            desc.depth = Int(SCATTERING_VOLUME_DEPTH)
            desc.storageMode = .private
            desc.usage = [.shaderWrite, .shaderRead]

            _scatteringVolume[0] = _device.makeTexture(descriptor: desc)
            _scatteringVolume[0]!.label = "Scattering Volume 0"

            _scatteringVolume[1] = _device.makeTexture(descriptor: desc)!
            _scatteringVolume[1]!.label = "Scattering Volume 1"

            scatteringAccumVolume = _device.makeTexture(descriptor: desc)
            scatteringAccumVolume!.label = "Scattering Volume Accum"
        }
    }
}
