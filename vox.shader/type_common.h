//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#import <simd/simd.h>
#import "config.h"

typedef enum {
    Position = 0,
    Normal = 1,
    UV_0 = 2,
    Tangent = 3,
    Bitangent = 4,
    Color_0 = 5,
    Weights_0 = 6,
    Joints_0 = 7,
    UV_1 = 8,
    UV_2 = 9,
    UV_3 = 10,
    UV_4 = 11,
    UV_5 = 12,
    UV_6 = 13,
    UV_7 = 14,
} Attributes;

typedef struct CameraData {
    matrix_float4x4 u_viewMat;
    matrix_float4x4 u_projMat;
    matrix_float4x4 u_VPMat;
    
    matrix_float4x4 u_viewInvMat;
    matrix_float4x4 u_projInvMat;
    matrix_float4x4 u_invViewProjectionMatrix;

    vector_float3 u_cameraPos;
    
    // Frustum planes in world space.
    vector_float4 worldFrustumPlanes[6];

    // A float4 containing the lower right 2x2 z,w block of inv projection matrix (column major);
    //   viewZ = (X * projZ + Z) / (Y * projZ + W)
    vector_float4 invProjZ;

    // Same as invProjZ but the result is a Z from 0...1 instead of N...F;
    //  effectively linearizes Z for easy visualization/storage.
    vector_float4 invProjZNormalized;
} CameraData;

struct RendererData {
    matrix_float4x4 u_localMat;
    matrix_float4x4 u_modelMat;
    matrix_float4x4 u_normalMat;
};

// Frame data common to most shaders.
typedef struct FrameConstants {
    CameraData cullParams;       // Parameters for culling.
    CameraData shadowCameraParams[SHADOW_CASCADE_COUNT]; // Camera data for cascade shadows cameras.

    // Previous view projection matrix for temporal reprojection.
    matrix_float4x4      prevViewProjectionMatrix;

    // Screen resolution and inverse for texture sampling.
    vector_float2        screenSize;
    vector_float2        invScreenSize;

    // Physical resolution and inverse for adjusting between screen and physical space.
    vector_float2        physicalSize;
    vector_float2        invPhysicalSize;

    // Lighting environment
    vector_float3        sunDirection;
    vector_float3        sunColor;
    vector_float3        skyColor;
    float               exposure;
    float               localLightIntensity;
    float               iblScale;
    float               iblSpecularScale;
    float               emissiveScale;
    float               scatterScale;
    float               wetness;

    vector_float3        globalNoiseOffset;

    vector_uint4         lightIndicesParams;

    // Distance scale for scattering.
    float               oneOverFarDistance;

    // Frame counter and time for varying values over frames and time.
    uint                frameCounter;
    float               frameTime;

    // Debug settings.
    uint                debugView;
    uint                visualizeCullingMode;
    uint                debugToggle;
} FrameConstants;

// MARK: - Light
struct EnvMapLight {
    vector_float3 diffuse;
    int mipMapLevel;
    float diffuseIntensity;
    float specularIntensity;
};

struct PointLightData {
    /// Position in XYZ, radius squared in W.
    vector_float4 posSqrRadius;
    /// RGB color of light.
    vector_float3 color;
    /// Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.
    uint flags;
};

// Point light information for culling.
typedef struct PointLightCullingData {
    // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
    vector_float4    posRadius;
} PointLightCullingData;

struct SpotLightData {
    /// Position in XYZ and height of spot in W.
    vector_float4 posAndHeight;
    /// Bounding sphere for quick visibility test.
    vector_float4 boundingSphere;
    /// RGB color of light.
    vector_float4 colorAndInnerAngle;
    /// Direction in XYZ, cone angle in W.
    vector_float4 dirAndOuterAngle;
    /// View projection matrix to light space.
    matrix_float4x4  viewProjMatrix;
    /// Optional flags. May include `LIGHT_FOR_TRANSPARENT_FLAG`.
    uint flags;
};

// Spot light information for culling.
typedef struct SpotLightCullingData {
    // Bounding sphere position in XYZ and radius of sphere in W.
    // Sign of radius:
    //  positive - transparency affecting light
    //  negative - light does not affect transparency
    vector_float4    posRadius;
    // View space position in XYZ and height of spot in W.
    vector_float4    posAndHeight;
    // View space direction in XYZ and cosine of outer angle in W.
    vector_float4    dirAndOuterAngle;
} SpotLightCullingData;

struct DirectLightData {
    vector_float3 color;
    vector_float3 direction;
};

// MARK: - Material
struct PBRBaseData {
    vector_float4 baseColor;

    vector_float3 emissiveColor;
    float normalTextureIntensity;

    float occlusionTextureIntensity;
    int occlusionTextureCoord;
    float clearCoat;
    float clearCoatRoughness;
};

struct PBRData {
    float metallic;
    float roughness;
    // aligned pad
    float pad1;
    float pad2;
};

struct PBRSpecularData {
    vector_float3 specularColor;
    float glossiness;
};

struct PostprocessData {
    float manualExposureValue;
    float exposureKey;
};

struct FogData {
    vector_float4 color;
    vector_float4 params;
};

// MARK: - Advance
// Indices for GBuffer render targets.
typedef enum GBufferIndex {
#if SUPPORT_SINGLE_PASS_DEFERRED
    GBufferLightIndex = 0,
#endif
    TraditionalGBufferStart,
    GBufferAlbedoAlphaIndex = TraditionalGBufferStart,
    GBufferNormalsIndex,
    GBufferEmissiveIndex,
    GBufferF0RoughnessIndex,
    GBufferIndexCount,
} GBufferIndex;

// Indices for members of the ShaderMaterial argument buffer.
typedef enum MaterialIndex {
    MaterialIndexBaseColor,
    MaterialIndexMetallicRoughness,
    MaterialIndexNormal,
    MaterialIndexEmissive,
    MaterialIndexAlpha,
    MaterialIndexHasMetallicRoughness,
    MaterialIndexHasEmissive,

#if USE_TEXTURE_STREAMING
    MaterialIndexBaseColorMip,
    MaterialIndexMetallicRoughnessMip,
    MaterialIndexNormalMip,
    MaterialIndexEmissiveMip,
#endif
} MaterialIndex;

// Indices for members of the ShaderLightParams argument buffer.
typedef enum LightParamsIndex {
    LightParamsIndexPointLights,
    LightParamsIndexSpotLights,
    LightParamsIndexPointLightIndices,
    LightParamsIndexSpotLightIndices,
    LightParamsIndexPointLightIndicesTransparent,
    LightParamsIndexSpotLightIndicesTransparent,
} LightParamsIndex;

// Indices for members of the GlobalTextures argument buffer.
typedef enum GlobalTextureIndexd {
    GlobalTextureIndexViewDepthPyramid,
    GlobalTextureIndexShadowMap,
    GlobalTextureIndexDFG,
    GlobalTextureIndexEnvMap,
    GlobalTextureIndexBlueNoise,
    GlobalTextureIndexPerlinNoise,
    GlobalTextureIndexSAO,
    GlobalTextureIndexScattering,
    GlobalTextureIndexSpotShadows,
}GlobalTextureIndexd;

// Indices for threadgroup storage during tiled light culling.
typedef enum TileThreadgroupIndex {
    TileThreadgroupIndexDepthBounds,
    TileThreadgroupIndexLightCounts,
    TileThreadgroupIndexTransparentPointLights,
    TileThreadgroupIndexTransparentSpotLights,
    TileThreadgroupIndexScatteringVolume,
} TileThreadgroupIndex;

// Options for culling visualization.
typedef enum VisualizationType {
    VisualizationTypeNone,
    VisualizationTypeChunkIndex,
    VisualizationTypeCascadeCount,
    VisualizationTypeFrustum,
    VisualizationTypeFrustumCull,
    VisualizationTypeFrustumCullOcclusion,
    VisualizationTypeFrustumCullOcclusionCull,
    VisualizationTypeCount
} VisualizationType;
