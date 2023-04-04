//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

// Stores results from the culling processes.
struct LightCullResult {
    // Output buffers for light bounds from executeCoarseCulling().
    var pointLightXYCoarseCullIndicesBuffer: MTLBuffer!
    var spotLightXYCoarseCullIndicesBuffer: MTLBuffer!

    // Output buffers for light indices from executeCulling().
    var pointLightIndicesBuffer: MTLBuffer!
    var pointLightIndicesTransparentBuffer: MTLBuffer!
    var spotLightIndicesBuffer: MTLBuffer!
    var spotLightIndicesTransparentBuffer: MTLBuffer!

    var pointLightClusterIndicesBuffer: MTLBuffer!
    var spotLightClusterIndicesBuffer: MTLBuffer!

    // Tile counts.
    var tileCountX: Int = 0
    var tileCountY: Int = 0

    var tileCountClusterX: Int = 0
    var tileCountClusterY: Int = 0
}

/// Encapsulates the state for culling lights.
class XLightCuller {
    // Device from initialization.
    private var _device: MTLDevice

    // For Tiled Light Culling on TBDR Apple Silicon GPUs.
    private var _renderCullingPipelineState: MTLRenderPipelineState!
    private var _pipelineStateHierarchical: MTLRenderPipelineState!
    private var _pipelineStateClustering: MTLRenderPipelineState!

    private var _initTilePipelineState: MTLRenderPipelineState!
    private var _depthBoundsTilePipelineState: MTLRenderPipelineState!

    // For compute based light culling on tradional GPUs.
    private var _computeCullingPipelineState: MTLComputePipelineState!

    // Common culling kenrels used on both traditional and TBDR GPUs.
    private var _hierarchicalClusteredPipelineState: MTLComputePipelineState!
    private var _spotCoarseCullPipelineState: MTLComputePipelineState!
    private var _pointCoarseCullPipelineState: MTLComputePipelineState!

    private var _lightCullingTileSize: Int
    private var _lightClusteringTileSize: Int

    /// Initializes this culling object, allocating compute pipelines.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         useLightCullingTileShaders: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int)
    {
        _device = device

        _lightCullingTileSize = lightCullingTileSize
        _lightClusteringTileSize = lightClusteringTileSize
        rebuildPipelines(with: library, useRasterizationRate: useRasterizationRate, useLightCullingTileShaders: useLightCullingTileShaders)
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool,
                          useLightCullingTileShaders: Bool)
    {
        var useRasterizationRate = useRasterizationRate
        let fc = MTLFunctionConstantValues()
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        fc.setConstantValue(&_lightCullingTileSize, type: .uint, index: Int(XFunctionConstIndexLightCullingTileSize.rawValue))
        fc.setConstantValue(&_lightClusteringTileSize, type: .uint, index: Int(XFunctionConstIndexLightClusteringTileSize.rawValue))

        if useLightCullingTileShaders {
            let tilePipelineStateDescriptor = MTLTileRenderPipelineDescriptor()
            let tilefc = fc.copy() as! MTLFunctionConstantValues

            tilePipelineStateDescriptor.colorAttachments[0].pixelFormat = .r32Float
            var tileSize = simd_uint2(UInt32(TILE_SHADER_WIDTH), UInt32(TILE_SHADER_HEIGHT))
            var depthBoundsDispatchSize = simd_uint2(UInt32(TILE_DEPTH_BOUNDS_DISPATCH_SIZE), UInt32(TILE_DEPTH_BOUNDS_DISPATCH_SIZE))

            tilefc.setConstantValue(&tileSize, type: .uint2, index: Int(XFunctionConstIndexTileSize.rawValue))
            tilefc.setConstantValue(&depthBoundsDispatchSize, type: .uint2, index: Int(XFunctionConstIndexDispatchSize.rawValue))

            tilePipelineStateDescriptor.tileFunction = library.makeFunction(name: "tileInit")!
            tilePipelineStateDescriptor.label = "tileInit"

            _initTilePipelineState = try? _device.makeRenderPipelineState(tileDescriptor: tilePipelineStateDescriptor,
                                                                          options: MTLPipelineOption(), reflection: nil)

            tilePipelineStateDescriptor.tileFunction = try! library.makeFunction(name: "tileDepthBounds", constantValues: tilefc)
            tilePipelineStateDescriptor.label = "tileDepthBounds"
            _depthBoundsTilePipelineState = try? _device.makeRenderPipelineState(tileDescriptor: tilePipelineStateDescriptor,
                                                                                 options: MTLPipelineOption(), reflection: nil)

            tilePipelineStateDescriptor.tileFunction = try! library.makeFunction(name: "tileLightCulling", constantValues: tilefc)
            tilePipelineStateDescriptor.label = "tileLightCulling"

            _renderCullingPipelineState = try? _device.makeRenderPipelineState(tileDescriptor: tilePipelineStateDescriptor,
                                                                               options: MTLPipelineOption(), reflection: nil)

            tilePipelineStateDescriptor.tileFunction = try! library.makeFunction(name: "tileLightCullingHierarchical", constantValues: tilefc)
            tilePipelineStateDescriptor.label = "tileLightCullingHierarchical"
            _pipelineStateHierarchical = try? _device.makeRenderPipelineState(tileDescriptor: tilePipelineStateDescriptor,
                                                                              options: MTLPipelineOption(), reflection: nil)
            tilePipelineStateDescriptor.tileFunction = try! library.makeFunction(name: "tileLightClustering", constantValues: tilefc)
            tilePipelineStateDescriptor.label = "tileLightClustering"
            _pipelineStateClustering = try? _device.makeRenderPipelineState(tileDescriptor: tilePipelineStateDescriptor,
                                                                            options: MTLPipelineOption(), reflection: nil)
        } else {
            _computeCullingPipelineState = newComputePipelineState(library: library,
                                                                   functionName: "traditionalLightCulling",
                                                                   label: "LightCulling", functionConstants: fc)
        }
        _spotCoarseCullPipelineState = newComputePipelineState(library: library,
                                                               functionName: "kernelSpotLightCoarseCulling",
                                                               label: "SpotLightCulling",
                                                               functionConstants: fc)
        _pointCoarseCullPipelineState = newComputePipelineState(library: library,
                                                                functionName: "kernelPointLightCoarseCulling",
                                                                label: "PointLightCulling",
                                                                functionConstants: fc)
        _hierarchicalClusteredPipelineState = newComputePipelineState(library: library,
                                                                      functionName: "traditionalLightClustering",
                                                                      label: "LightClustring",
                                                                      functionConstants: fc)
    }

    /// Initializes a LightCullResult object with buffers based on the view size and light counts.
    func createResultInstance(viewSize: MTLSize,
                              lightCount: simd_uint2) -> LightCullResult
    {
        var inst = LightCullResult()

        inst.tileCountX = divideRoundUp(numerator: viewSize.width, denominator: _lightCullingTileSize)
        inst.tileCountY = divideRoundUp(numerator: viewSize.height, denominator: _lightCullingTileSize)

        let tileCount = inst.tileCountX * inst.tileCountY

        inst.pointLightIndicesBuffer = _device.makeBuffer(
            length: tileCount * Int(MAX_LIGHTS_PER_TILE) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.pointLightIndicesBuffer.label = "Point Light Indices (1B/l x \(MAX_LIGHTS_PER_TILE) l/tile x \(tileCount) tiles)"

        inst.pointLightIndicesTransparentBuffer = _device.makeBuffer(
            length: tileCount * Int(MAX_LIGHTS_PER_TILE) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.pointLightIndicesTransparentBuffer.label = "Point Light Indices Transparent (1B/l x \(MAX_LIGHTS_PER_TILE) l/tile x \(tileCount) tiles)"

        inst.spotLightIndicesBuffer = _device.makeBuffer(
            length: tileCount * Int(MAX_LIGHTS_PER_TILE) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.spotLightIndicesBuffer.label = "Spot Light Indices (1B/l x \(MAX_LIGHTS_PER_TILE) l/tile x \(tileCount) tiles)"

        inst.spotLightIndicesTransparentBuffer = _device.makeBuffer(
            length: tileCount * Int(MAX_LIGHTS_PER_TILE) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.spotLightIndicesTransparentBuffer.label = "Spot Light Indices Transparent (1B/l x \(MAX_LIGHTS_PER_TILE) l/tile x \(tileCount) tiles)"

        let pointLightCount = max(lightCount.x, 1)
        let spotLightCount = max(lightCount.y, 1)
        inst.pointLightXYCoarseCullIndicesBuffer = _device.makeBuffer(
            length: Int(pointLightCount) * MemoryLayout<simd_ushort4>.stride,
            options: .storageModePrivate
        )
        inst.pointLightXYCoarseCullIndicesBuffer.label = "Point Light Coarse Cull XY (8B/l x \(pointLightCount) l)"

        inst.spotLightXYCoarseCullIndicesBuffer = _device.makeBuffer(
            length: Int(spotLightCount) * MemoryLayout<simd_ushort4>.stride,
            options: .storageModePrivate
        )
        inst.spotLightXYCoarseCullIndicesBuffer.label = "Spot Light Coarse Cull XY (8B/l x \(spotLightCount) l)"

        inst.tileCountClusterX = divideRoundUp(numerator: viewSize.width, denominator: _lightCullingTileSize)
        inst.tileCountClusterY = divideRoundUp(numerator: viewSize.height, denominator: _lightCullingTileSize)
        let clusterCount = inst.tileCountClusterX * inst.tileCountClusterY * Int(LIGHT_CLUSTER_DEPTH)

        inst.pointLightClusterIndicesBuffer = _device.makeBuffer(
            length: clusterCount * Int(MAX_LIGHTS_PER_CLUSTER) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.pointLightClusterIndicesBuffer.label = "Point Light Cluster Indices (1B/l x \(MAX_LIGHTS_PER_CLUSTER) l/cluster x \(clusterCount) clusters)"

        inst.spotLightClusterIndicesBuffer = _device.makeBuffer(
            length: clusterCount * Int(MAX_LIGHTS_PER_CLUSTER) * MemoryLayout<UInt8>.stride,
            options: .storageModePrivate
        )
        inst.spotLightClusterIndicesBuffer.label = "Spot Light Cluster Indices (1B/l x \(MAX_LIGHTS_PER_CLUSTER) l/cluster x \(clusterCount) clusters)"

        return inst
    }

    /// Coarsely culls a set of lights to calculate their XY bounds.
    func executeCoarseCulling(result: inout LightCullResult,
                              commandBuffer: MTLCommandBuffer,
                              pointLightCount: Int,
                              spotLightCount: Int,
                              pointLights: MTLBuffer,
                              spotLights: MTLBuffer,
                              frameDataBuffer: MTLBuffer,
                              cameraParamsBuffer: MTLBuffer,
                              rrMapData: MTLBuffer?,
                              nearPlane: Float)
    {
        // The two dispatches in this encoder write to non-aliasing memory.
        if let computeEncoder = commandBuffer.makeComputeCommandEncoder(dispatchType: .concurrent) {
            computeEncoder.label = "LightCoarseCulling"
            var nearPlane = nearPlane
            computeEncoder.setComputePipelineState(_pointCoarseCullPipelineState)
            computeEncoder.setBuffer(frameDataBuffer, offset: 0, index: Int(XBufferIndexFrameData.rawValue))
            computeEncoder.setBuffer(cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))
            computeEncoder.setBytes(&nearPlane, length: MemoryLayout<Float>.stride, index: Int(XBufferIndexNearPlane.rawValue))
            computeEncoder.setBuffer(rrMapData, offset: 0, index: Int(XBufferIndexRasterizationRateMap.rawValue))

            if pointLightCount > 0 {
                var pointLightCount = pointLightCount
                computeEncoder.setBuffer(pointLights, offset: 0, index: Int(XBufferIndexPointLights.rawValue))
                computeEncoder.setBytes(&pointLightCount, length: MemoryLayout<Int>.stride,
                                        index: Int(XBufferIndexLightCount.rawValue))
                computeEncoder.setBuffer(result.pointLightXYCoarseCullIndicesBuffer, offset: 0,
                                         index: Int(XBufferIndexPointLightCoarseCullingData.rawValue))
                computeEncoder.dispatchThreadgroups(MTLSize(width: divideRoundUp(numerator: pointLightCount, denominator: 64), height: 1, depth: 1),
                                                    threadsPerThreadgroup: MTLSize(width: 64, height: 1, depth: 1))
            }

            if spotLightCount > 0 {
                var spotLightCount = spotLightCount
                computeEncoder.setComputePipelineState(_spotCoarseCullPipelineState)
                computeEncoder.setBuffer(spotLights, offset: 0, index: Int(XBufferIndexSpotLights.rawValue))
                computeEncoder.setBytes(&spotLightCount, length: MemoryLayout<Int>.stride,
                                        index: Int(XBufferIndexLightCount.rawValue))
                computeEncoder.setBuffer(result.spotLightXYCoarseCullIndicesBuffer, offset: 0,
                                         index: Int(XBufferIndexSpotLightCoarseCullingData.rawValue))
                computeEncoder.dispatchThreadgroups(MTLSize(width: divideRoundUp(numerator: spotLightCount, denominator: 64), height: 1, depth: 1),
                                                    threadsPerThreadgroup: MTLSize(width: 64, height: 1, depth: 1))
            }
            computeEncoder.endEncoding()
        }
    }

    /// Uses a traditional compute kernel to cull a set of lights based on depth,
    ///  using coarse culled results for XY range.
    func executeTraditionalCulling(result: inout LightCullResult,
                                   pointLightCount: Int,
                                   spotLightCount: Int,
                                   pointLights: MTLBuffer,
                                   spotLights: MTLBuffer,
                                   frameDataBuffer: MTLBuffer,
                                   cameraParamsBuffer: MTLBuffer,
                                   rrMapData: MTLBuffer?,
                                   depthTexture: MTLTexture,
                                   commandBuffer: MTLCommandBuffer)
    {
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            encoder.label = "LightCulling"

            encoder.setComputePipelineState(_computeCullingPipelineState)
            encoder.setBuffer(result.pointLightIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexPointLightIndices.rawValue))
            encoder.setBuffer(result.pointLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentPointLightIndices.rawValue))
            encoder.setBuffer(result.spotLightIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexSpotLightIndices.rawValue))
            encoder.setBuffer(result.spotLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentSpotLightIndices.rawValue))

            encoder.setBuffer(frameDataBuffer, offset: 0, index: Int(XBufferIndexFrameData.rawValue))
            encoder.setBuffer(cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))
            encoder.setBuffer(pointLights, offset: 0, index: Int(XBufferIndexPointLights.rawValue))
            encoder.setBuffer(spotLights, offset: 0, index: Int(XBufferIndexSpotLights.rawValue))

            var lightCount = [pointLightCount, spotLightCount]
            encoder.setBytes(&lightCount, length: MemoryLayout<Int>.stride,
                             index: Int(XBufferIndexLightCount.rawValue))
            encoder.setTexture(depthTexture, index: 0)

            encoder.setBuffer(rrMapData, offset: 0, index: Int(XBufferIndexRasterizationRateMap.rawValue))

            encoder.setBuffer(result.pointLightXYCoarseCullIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexPointLightCoarseCullingData.rawValue))
            encoder.setBuffer(result.spotLightXYCoarseCullIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexSpotLightCoarseCullingData.rawValue))

            encoder.dispatchThreadgroups(MTLSize(width: result.tileCountX, height: result.tileCountY, depth: 1),
                                         threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1))

            encoder.endEncoding()
        }
    }

    /// Uses a tile shader to both cull and cluster a set of lights based on depth,
    ///  using coarse culled results for XY range.
    func executeTileCulling(result: inout LightCullResult,
                            clustered: Bool,
                            pointLightCount: Int,
                            spotLightCount: Int,
                            pointLights: MTLBuffer,
                            spotLights: MTLBuffer,
                            frameDataBuffer: MTLBuffer,
                            cameraParamsBuffer: MTLBuffer,
                            rrMapData: MTLBuffer?,
                            depthTexture _: MTLTexture,
                            encoder: MTLRenderCommandEncoder)
    {
        encoder.setRenderPipelineState(_initTilePipelineState)
        encoder.dispatchThreadsPerTile(MTLSizeMake(1, 1, 1))

        encoder.setTileBuffer(cameraParamsBuffer, offset: 0, index: Int(XBufferIndexCameraParams.rawValue))

        encoder.setRenderPipelineState(_depthBoundsTilePipelineState)
        encoder.dispatchThreadsPerTile(MTLSizeMake(Int(TILE_DEPTH_BOUNDS_DISPATCH_SIZE),
                                                   Int(TILE_DEPTH_BOUNDS_DISPATCH_SIZE), 1))

        encoder.setTileBuffer(result.pointLightIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexPointLightIndices.rawValue))
        encoder.setTileBuffer(result.pointLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentPointLightIndices.rawValue))
        encoder.setTileBuffer(result.spotLightIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexSpotLightIndices.rawValue))
        encoder.setTileBuffer(result.spotLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentSpotLightIndices.rawValue))
        encoder.setTileBuffer(frameDataBuffer, offset: 0, index: Int(XBufferIndexFrameData.rawValue))
        encoder.setTileBuffer(pointLights, offset: 0, index: Int(XBufferIndexPointLights.rawValue))
        encoder.setTileBuffer(spotLights, offset: 0, index: Int(XBufferIndexSpotLights.rawValue))

        var lightCount = [pointLightCount, spotLightCount]
        encoder.setTileBytes(&lightCount, length: MemoryLayout<Int>.stride * 2,
                             index: Int(XBufferIndexLightCount.rawValue))
        encoder.setTileBuffer(result.pointLightXYCoarseCullIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexPointLightCoarseCullingData.rawValue))
        encoder.setTileBuffer(result.spotLightXYCoarseCullIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexSpotLightCoarseCullingData.rawValue))

        encoder.setTileBuffer(rrMapData, offset: 0, index: Int(XBufferIndexRasterizationRateMap.rawValue))

        if clustered {
            encoder.setRenderPipelineState(_pipelineStateHierarchical)
            encoder.dispatchThreadsPerTile(MTLSizeMake(Int(TILE_SHADER_WIDTH), Int(TILE_SHADER_HEIGHT), 1))

            encoder.setTileBuffer(result.pointLightClusterIndicesBuffer, offset: 0,
                                  index: Int(XBufferIndexPointLightIndices.rawValue))
            encoder.setTileBuffer(result.spotLightClusterIndicesBuffer, offset: 0,
                                  index: Int(XBufferIndexSpotLightIndices.rawValue))

            encoder.setRenderPipelineState(_pipelineStateClustering)
            encoder.dispatchThreadsPerTile(MTLSizeMake(8, 8, 1))
        } else {
            encoder.setRenderPipelineState(_renderCullingPipelineState)
            encoder.dispatchThreadsPerTile(MTLSizeMake(Int(TILE_SHADER_WIDTH), Int(TILE_SHADER_HEIGHT), 1))
        }
    }

    // Executes traditional compute based light clustering.
    func executeTraditionalClustering(result: inout LightCullResult,
                                      commandBuffer: MTLCommandBuffer,
                                      pointLightCount: Int,
                                      spotLightCount: Int,
                                      pointLights: MTLBuffer,
                                      spotLights: MTLBuffer,
                                      frameDataBuffer: MTLBuffer,
                                      cameraParamsBuffer: MTLBuffer,
                                      rrMapData: MTLBuffer?)
    {
        var lightCount = [pointLightCount, spotLightCount]

        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            encoder.label = "LightClustering"

            encoder.setBuffer(result.pointLightClusterIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexPointLightIndices.rawValue))
            encoder.setBuffer(result.pointLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentPointLightIndices.rawValue))
            encoder.setBuffer(result.spotLightClusterIndicesBuffer, offset: 0,
                              index: Int(XBufferIndexSpotLightIndices.rawValue))
            encoder.setBuffer(result.spotLightIndicesTransparentBuffer, offset: 0,
                              index: Int(XBufferIndexTransparentSpotLightIndices.rawValue))

            encoder.setBuffer(frameDataBuffer, offset: 0,
                              index: Int(XBufferIndexFrameData.rawValue))
            encoder.setBuffer(cameraParamsBuffer, offset: 0,
                              index: Int(XBufferIndexCameraParams.rawValue))
            encoder.setBuffer(pointLights, offset: 0,
                              index: Int(XBufferIndexPointLights.rawValue))
            encoder.setBuffer(spotLights, offset: 0,
                              index: Int(XBufferIndexSpotLights.rawValue))

            encoder.setBytes(&lightCount, length: MemoryLayout<Int>.stride * 2,
                             index: Int(XBufferIndexLightCount.rawValue))
            encoder.setBuffer(rrMapData, offset: 0, index: Int(XBufferIndexRasterizationRateMap.rawValue))
            encoder.setBuffer(result.pointLightXYCoarseCullIndicesBuffer, offset: 0, index: 10)
            encoder.setBuffer(result.spotLightXYCoarseCullIndicesBuffer, offset: 0, index: 11)

            encoder.setComputePipelineState(_hierarchicalClusteredPipelineState)
            encoder.dispatchThreadgroups(MTLSize(width: result.tileCountClusterX,
                                                 height: result.tileCountClusterY, depth: 1),
                                         threadsPerThreadgroup: MTLSize(width: 1, height: 1, depth: Int(LIGHT_CLUSTER_DEPTH)))
            encoder.endEncoding()
        }
    }
}
