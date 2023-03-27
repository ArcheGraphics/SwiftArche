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
    /// Initializes this culling object, allocating compute pipelines.
    init(with device: MTLDevice,
         library: MTLLibrary,
         useRasterizationRate: Bool,
         useLightCullingTileShaders: Bool,
         lightCullingTileSize: Int,
         lightClusteringTileSize: Int) {
    }

    func rebuildPipelines(with library: MTLLibrary,
                          useRasterizationRate: Bool,
                          useLightCullingTileShaders: Bool) {
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

