//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>

#import "Config.h"

// Global function constant indices.
typedef enum XFunctionConstIndex {
    XFunctionConstIndexAlphaMask,
    XFunctionConstIndexTransparent,
    XFunctionConstIndexTileSize,
    XFunctionConstIndexDispatchSize,
    XFunctionConstIndexDebugView,
    XFunctionConstIndexLightCluster,
    XFunctionConstIndexRasterizationRate,
    XFunctionConstIndexSinglePassDeferred,
    XFunctionConstIndexLightCullingTileSize,
    XFunctionConstIndexLightClusteringTileSize,
    XFunctionConstIndexUseOcclusionCulling,
    XFunctionConstIndexEncodeAlphaMask,
    XFunctionConstIndexEncodeToDepthOnly,
    XFunctionConstIndexEncodeToMain,
    XFunctionConstIndexVisualizeCulling,
    XFunctionConstIndexPackCommands,
    XFunctionConstIndexFilteredCulling,
    XFunctionConstIndexTemporalAntialiasing
} XFunctionConstIndex;

// Indices for GBuffer render targets.
typedef enum XGBufferIndex {
#if SUPPORT_SINGLE_PASS_DEFERRED
    XGBufferLightIndex = 0,
#endif
    XTraditionalGBufferStart,
    XGBufferAlbedoAlphaIndex = XTraditionalGBufferStart,
    XGBufferNormalsIndex,
    XGBufferEmissiveIndex,
    XGBufferF0RoughnessIndex,
    XGBufferIndexCount,
} XGBufferIndex;

// Indices for buffer bindings.
typedef enum XBufferIndex {
    XBufferIndexFrameData = 0,
    XBufferIndexCameraParams,
    XBufferIndexRasterizationRateMap,
    XBufferIndexCommonCount,

    XBufferIndexCullParams = XBufferIndexFrameData,

    XBufferIndexVertexMeshPositions = XBufferIndexCommonCount,
    XBufferIndexVertexMeshGenerics,
    XBufferIndexVertexMeshNormals,
    XBufferIndexVertexMeshTangents,
    XBufferIndexVertexCount,

    XBufferIndexFragmentMaterial = XBufferIndexCommonCount,
    XBufferIndexFragmentGlobalTextures,
    XBufferIndexFragmentLightParams,
    XBufferIndexFragmentChunkViz,
    XBufferIndexFragmentCount,

    XBufferIndexPointLights = XBufferIndexCommonCount,
    XBufferIndexSpotLights,
    XBufferIndexLightCount,
    XBufferIndexPointLightIndices,
    XBufferIndexSpotLightIndices,
    XBufferIndexTransparentPointLightIndices,
    XBufferIndexTransparentSpotLightIndices,
    XBufferIndexPointLightCoarseCullingData,
    XBufferIndexSpotLightCoarseCullingData,
    XBufferIndexNearPlane,
    XBufferIndexHeatmapParams,
    XBufferIndexDepthPyramidSize,

    XBufferIndexComputeEncodeArguments = XBufferIndexCommonCount,
    XBufferIndexComputeCullCameraParams,
#if SUPPORT_CSM_GENERATION_WITH_VERTEX_AMPLIFICATION
    XBufferIndexComputeCullCameraParams2,
#endif
    XBufferIndexComputeFrameData,
    XBufferIndexComputeMaterial,
    XBufferIndexComputeChunks,
    XBufferIndexComputeChunkViz,
    XBufferIndexComputeExecutionRange,
    XBufferIndexComputeCount,

    XBufferIndexVertexDepthOnlyICBBufferCount = XBufferIndexVertexMeshPositions + 1,
    XBufferIndexVertexDepthOnlyICBAlphaMaskBufferCount = XBufferIndexVertexMeshGenerics + 1,
    XBufferIndexVertexICBBufferCount = XBufferIndexVertexCount,

    XBufferIndexFragmentICBBufferCount = XBufferIndexFragmentCount,
    XBufferIndexFragmentDepthOnlyICBAlphaMaskBufferCount = XBufferIndexFragmentMaterial + 1,
} XBufferIndex;

// Indices for vertex attributes.
typedef enum XVertexAttribute {
    XVertexAttributePosition = 0,
    XVertexAttributeNormal = 1,
    XVertexAttributeTangent = 2,
    XVertexAttributeTexcoord = 3,
} XVertexAttribute;

// Indices for members of the XShaderMaterial argument buffer.
typedef enum XMaterialIndex {
    XMaterialIndexBaseColor,
    XMaterialIndexMetallicRoughness,
    XMaterialIndexNormal,
    XMaterialIndexEmissive,
    XMaterialIndexAlpha,
    XMaterialIndexHasMetallicRoughness,
    XMaterialIndexHasEmissive,

#if USE_TEXTURE_STREAMING
    XMaterialIndexBaseColorMip,
    XMaterialIndexMetallicRoughnessMip,
    XMaterialIndexNormalMip,
    XMaterialIndexEmissiveMip,
#endif
} XMaterialIndex;

// Indices for members of the XShaderLightParams argument buffer.
typedef enum XLightParamsIndex {
    XLightParamsIndexPointLights,
    XLightParamsIndexSpotLights,
    XLightParamsIndexPointLightIndices,
    XLightParamsIndexSpotLightIndices,
    XLightParamsIndexPointLightIndicesTransparent,
    XLightParamsIndexSpotLightIndicesTransparent,
} XLightParamsIndex;

// Indices for members of the XGlobalTextures argument buffer.
typedef enum XGlobalTextureIndexd {
    XGlobalTextureIndexViewDepthPyramid,
    XGlobalTextureIndexShadowMap,
    XGlobalTextureIndexDFG,
    XGlobalTextureIndexEnvMap,
    XGlobalTextureIndexBlueNoise,
    XGlobalTextureIndexPerlinNoise,
    XGlobalTextureIndexSAO,
    XGlobalTextureIndexScattering,
    XGlobalTextureIndexSpotShadows,
} XGlobalTextureIndexd;

// Indices for threadgroup storage during tiled light culling.
typedef enum XTileThreadgroupIndex {
    XTileThreadgroupIndexDepthBounds,
    XTileThreadgroupIndexLightCounts,
    XTileThreadgroupIndexTransparentPointLights,
    XTileThreadgroupIndexTransparentSpotLights,
    XTileThreadgroupIndexScatteringVolume,
} XTileThreadgroupIndex;

// Options for culling visualization.
typedef enum XVisualizationType {
    XVisualizationTypeNone,
    XVisualizationTypeChunkIndex,
    XVisualizationTypeCascadeCount,
    XVisualizationTypeFrustum,
    XVisualizationTypeFrustumCull,
    XVisualizationTypeFrustumCullOcclusion,
    XVisualizationTypeFrustumCullOcclusionCull,
    XVisualizationTypeCount
} XVisualizationType;

// Matrices stored and generated internally within the camera object.
typedef struct XCameraParams {
    // Standard camera matrices.
    simd_float4x4 viewMatrix;
    simd_float4x4 projectionMatrix;
    simd_float4x4 viewProjectionMatrix;

    // Inverse matrices.
    simd_float4x4 invViewMatrix;
    simd_float4x4 invProjectionMatrix;
    simd_float4x4 invViewProjectionMatrix;

    // Frustum planes in world space.
    simd_float4 worldFrustumPlanes[6];

    // A float4 containing the lower right 2x2 z,w block of inv projection matrix (column major);
    //   viewZ = (X * projZ + Z) / (Y * projZ + W)
    simd_float4 invProjZ;

    // Same as invProjZ but the result is a Z from 0...1 instead of N...F;
    //  effectively linearizes Z for easy visualization/storage.
    simd_float4 invProjZNormalized;
} XCameraParams;

// Frame data common to most shaders.
typedef struct XFrameConstants {
    XCameraParams cullParams;       // Parameters for culling.
    XCameraParams shadowCameraParams[SHADOW_CASCADE_COUNT]; // Camera data for cascade shadows cameras.

    // Previous view projection matrix for temporal reprojection.
    simd_float4x4 prevViewProjectionMatrix;

    // Screen resolution and inverse for texture sampling.
    simd_float2 screenSize;
    simd_float2 invScreenSize;

    // Physical resolution and inverse for adjusting between screen and physical space.
    simd_float2 physicalSize;
    simd_float2 invPhysicalSize;

    // Lighting environment
    simd_float3 sunDirection;
    simd_float3 sunColor;
    simd_float3 skyColor;
    float exposure;
    float localLightIntensity;
    float iblScale;
    float iblSpecularScale;
    float emissiveScale;
    float scatterScale;
    float wetness;

    simd_float3 globalNoiseOffset;

    simd_uint4 lightIndicesParams;

    // Distance scale for scattering.
    float oneOverFarDistance;

    // Frame counter and time for varying values over frames and time.
    uint frameCounter;
    float frameTime;

    // Debug settings.
    uint debugView;
    uint visualizeCullingMode;
    uint debugToggle;
} XFrameConstants;

// Point light information.
typedef struct XPointLightData {
    simd_float4 posSqrRadius;   // Position in XYZ, radius squared in W.
    simd_float3 color;          // RGB color of light.
    uint flags;          // Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.
} XPointLightData;

// Spot light information.
typedef struct XSpotLightData {
    simd_float4 boundingSphere;     // Bounding sphere for quick visibility test.
    simd_float4 posAndHeight;       // Position in XYZ and height of spot in W.
    simd_float4 colorAndInnerAngle; // RGB color of light.
    simd_float4 dirAndOuterAngle;   // Direction in XYZ, cone angle in W.
    simd_float4x4 viewProjMatrix;     // View projection matrix to light space.
    uint flags;              // Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.

} XSpotLightData;

// Point light information for culling.
typedef struct XPointLightCullingData {
    simd_float4 posRadius;          // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
} XPointLightCullingData;

// Spot light information for culling.
typedef struct XSpotLightCullingData {
    simd_float4 posRadius;          // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
    simd_float4 posAndHeight;       // View space position in XYZ and height of spot in W.
    simd_float4 dirAndOuterAngle;   // View space direction in XYZ and cosine of outer angle in W.
} XSpotLightCullingData;
