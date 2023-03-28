//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

class TerrainRenderer: Renderer {
    struct HabitatTextures {
        var diffSpecTextureArray: MTLTexture?
        var normalTextureArray: MTLTexture?
    }

    // Terrain rendering data
    var _terrainTextures = [HabitatTextures](repeating: HabitatTextures(), count: 4)
    var _terrainParamsBuffer: MTLBuffer
    var _terrainHeight: MTLTexture
    var _terrainNormalMap: MTLTexture
    var _terrainPropertiesMap: MTLTexture
    var _targetHeightmap: MTLTexture

    // Tesselation data
    var _visiblePatchesTessFactorBfr: MTLBuffer
    var _visiblePatchIndicesBfr: MTLBuffer
    var _tessellationScale: Float

    // Render pipelines
    var _pplRnd_TerrainMainView: MTLRenderPipelineState
    var _iabBufferIndex_PplTerrainMainView: Int
    var _pplRnd_TerrainShadow: MTLRenderPipelineState

    // Compute pipelines
    var _pplCmp_FillInTesselationFactors: MTLComputePipelineState
    var _pplCmp_BakeNormalsMips: MTLComputePipelineState
    var _pplCmp_BakePropertiesMips: MTLComputePipelineState
    var _pplCmp_ClearTexture: MTLComputePipelineState
    var _pplCmp_UpdateHeightmap: MTLComputePipelineState
    var _pplCmp_CopyChannel1Only: MTLComputePipelineState

    public private(set) var precomputationCompleted: Bool
    public private(set) var terrainParamsBuffer: MTLBuffer
    public private(set) var terrainHeight: MTLTexture
    public private(set) var terrainNormalMap: MTLTexture
    public private(set) var terrainPropertiesMap: MTLTexture
    public var terrainWorldBoundsMin: Vector3 {
        Vector3(TERRAIN_SCALE / -2.0, 0, TERRAIN_SCALE / -2.0)
    }
    public var terrainWorldBoundsMax: Vector3 {
        Vector3(TERRAIN_SCALE / 2.0, TERRAIN_HEIGHT, TERRAIN_SCALE / 2.0)
    }
    
    required init() {
        
    }
}
