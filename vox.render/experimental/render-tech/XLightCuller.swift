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
    var _device: MTLDevice

    // For Tiled Light Culling on TBDR Apple Silicon GPUs.
    var _renderCullingPipelineState: MTLRenderPipelineState!
    var _pipelineStateHierarchical: MTLRenderPipelineState!
    var _pipelineStateClustering: MTLRenderPipelineState!

    var _initTilePipelineState: MTLRenderPipelineState!
    var _depthBoundsTilePipelineState: MTLRenderPipelineState!

    // For compute based light culling on tradional GPUs.
    var _computeCullingPipelineState: MTLComputePipelineState!

    // Common culling kenrels used on both traditional and TBDR GPUs.
    var _hierarchicalClusteredPipelineState: MTLComputePipelineState!
    var _spotCoarseCullPipelineState: MTLComputePipelineState!
    var _pointCoarseCullPipelineState: MTLComputePipelineState!

    var _lightCullingTileSize: Int
    var _lightClusteringTileSize: Int


    /// Initializes this culling object, allocating compute pipelines.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         useLightCullingTileShaders: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int) {
        _device = device

        _lightCullingTileSize = lightCullingTileSize
        _lightClusteringTileSize = lightClusteringTileSize
        rebuildPipelines(with: library, useRasterizationRate: useRasterizationRate, useLightCullingTileShaders: useLightCullingTileShaders)
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool,
                          useLightCullingTileShaders: Bool) {
        var useRasterizationRate = useRasterizationRate
        let fc = MTLFunctionConstantValues()
        fc.setConstantValue(&useRasterizationRate, type: .bool, index: Int(XFunctionConstIndexRasterizationRate.rawValue))
        fc.setConstantValue(&_lightCullingTileSize, type: .uint, index: Int(XFunctionConstIndexLightCullingTileSize.rawValue))
        fc.setConstantValue(&_lightClusteringTileSize, type: .uint, index: Int(XFunctionConstIndexLightClusteringTileSize.rawValue))

        if (useLightCullingTileShaders) {
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
                              lightCount: simd_uint2) -> LightCullResult {
        LightCullResult()
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
                              rrData: MTLBuffer?,
                              nearPlane: Float) {
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
                                   rrData: MTLBuffer?,
                                   depthTexture: MTLBuffer,
                                   onCommandBuffer: MTLBuffer) {
    }

    /// Uses a tile shader to both cull and cluster a set of lights based on depth,
    ///  using coarse culled results for XY range.
    #if SUPPORT_LIGHT_CULLING_TILE_SHADERS
    func executeTileCulling(result: inout LightCullResult,
                            clustered: Bool,
                            pointLightCount: Int,
                            spotLightCount: Int,
                            pointLights: MTLBuffer,
                            spotLights: MTLBuffer,
                            frameDataBuffer: MTLBuffer,
                            cameraParamsBuffer: MTLBuffer,
                            rrData: MTLBuffer?,
                            depthTexture: MTLTexture,
                            onEncoder: MTLRenderCommandEncoder) {
    }
    #endif

    // Executes traditional compute based light clustering.
    func executeTraditionalClustering(result: inout LightCullResult,
                                      commandBuffer: MTLCommandBuffer,
                                      pointLightCount: Int,
                                      spotLightCount: Int,
                                      pointLights: MTLBuffer,
                                      spotLights: MTLBuffer,
                                      frameDataBuffer: MTLBuffer,
                                      cameraParamsBuffer: MTLBuffer,
                                      rrData: MTLBuffer?) {

    }
}

