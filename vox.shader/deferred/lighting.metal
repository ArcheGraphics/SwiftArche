//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "../function_common.h"
#include "../function_constant.h"
#include "../shader_common.h"
#include "lighting_common.h"

//------------------------------------------------------------------------------

// Performs tiled lighting, reading the GBuffer from either tile memory or
//  output textures.
// Executes after FSQuadVertexShader so that it renders as a full screen pass
//  with an input texcoord in screen space.
fragment xhalf4 tiledLightingShader(SimpleTexVertexOut in [[ stage_in ]],
                                    constant FrameConstants &frameData [[ buffer(0) ]],
                                    constant CameraData &cameraParams [[ buffer(1) ]],
                                    constant rasterization_rate_map_data * rrData [[ buffer(2), function_constant(needRasterizationRate) ]],
                                    constant PointLightData * pointLightBuffer [[ buffer(3) ]],
                                    constant SpotLightData * spotLightBuffer [[ buffer(4) ]],
                                    constant uint8_t * pointLightIndices [[ buffer(5) ]],
                                    constant uint8_t * spotLightIndices  [[ buffer(6) ]],
                                    xhalf4 albedoTarget [[color(0), function_constant(needSinglePassDeferred)]],
                                    xhalf4 normalTarget [[color(1), function_constant(needSinglePassDeferred)]],
                                    xhalf4 emissiveTarget [[color(2), function_constant(needSinglePassDeferred)]],
                                    xhalf4 F0RoughnessTarget [[color(3), function_constant(needSinglePassDeferred)]],
                                    texture2d<xhalf, access::sample> albedoeTex [[texture(0), function_constant(needTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> normalTex [[texture(1), function_constant(needTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> emissiveTex [[texture(2), function_constant(needTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> F0RoughnessTex [[texture(3), function_constant(needTraditionalDeferred)]],
                                    depth2d<float, access::sample> inDepth [[texture(4)]],
                                    depth2d_array<float, access::sample> shadowMap [[texture (5)]],
#if USE_SCATTERING_VOLUME
                                    texture3d<xhalf, access::sample> scattering [[texture(6)]],
#endif
                                    texture2d<xhalf, access::sample> dfgLutTex [[texture(7)]],
                                    texturecube<xhalf, access::sample> envMap [[texture(8)]],
#if USE_SCALABLE_AMBIENT_OBSCURANCE
                                    texture2d<xhalf, access::sample> saoTexture [[texture(9)]],
#endif
#if USE_SPOT_LIGHT_SHADOWS
                                    depth2d_array<float, access::sample> spotShadowMaps [[texture(10)]],
#endif
                                    texture2d<float, access::read> blueNoiseTexture [[texture(11)]]) {
    constexpr sampler nearestSampler(mip_filter::nearest, mag_filter::nearest, min_filter::nearest, address::clamp_to_edge);

    float2 physicalCoord = in.texCoord;
#if SUPPORT_RASTERIZATION_RATE
    if (needRasterizationRate) {
        // We are currently drawing inside compressed space, so we have to fix up screen space.
        rasterization_rate_map_decoder decoder(*rrData);
        physicalCoord = decoder.map_screen_to_physical_coordinates(physicalCoord * frameData.screenSize) * frameData.invPhysicalSize;
    }
#endif

#if USE_SCALABLE_AMBIENT_OBSCURANCE
    float aoSample = saoTexture.sample(nearestSampler, physicalCoord).x;
#else
    float aoSample = 1.0f;
#endif

    xhalf4 albedoSample;
    xhalf4 normalSample;
    xhalf4 emissiveSample;
    xhalf4 F0RoughnessSample;

    if(needSinglePassDeferred) {
        albedoSample = albedoTarget;
        normalSample = normalTarget;
        emissiveSample = emissiveTarget;
        F0RoughnessSample = F0RoughnessTarget;
    } else {
        albedoSample = albedoeTex.sample(nearestSampler, physicalCoord);
        normalSample = normalTex.sample(nearestSampler, physicalCoord);
        emissiveSample = emissiveTex.sample(nearestSampler, physicalCoord);
        F0RoughnessSample = F0RoughnessTex.sample(nearestSampler, physicalCoord);
    }

    PixelSurfaceData surfaceData;
    surfaceData.normal      = (xhalf3)normalize((float3)normalSample.xyz); // normalizing half3 normal causes banding
    surfaceData.albedo      = albedoSample.xyz;
    surfaceData.F0          = mix(F0RoughnessSample.xyz, (xhalf)0.02, (xhalf)frameData.wetness);
    surfaceData.roughness   = mix(F0RoughnessSample.w, (xhalf)0.1, (xhalf)frameData.wetness);
    surfaceData.alpha       = 1.0f;
    surfaceData.emissive    = emissiveSample.rgb;

    const float depth = inDepth.sample(nearestSampler, physicalCoord);
    float4 worldPosition = worldPositionForTexcoord(in.texCoord, depth, cameraParams);

    uint tileIdx;
    if (needLightCluster) {
        uint tileX = in.position.x / lightClusteringTileSize;
        uint tileY = in.position.y / lightClusteringTileSize;

#if LOCAL_LIGHT_SCATTERING
        uint cluster = zToScatterDepth(linearizeDepth(cameraParams, depth)) * LIGHT_CLUSTER_DEPTH;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#else
        float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
        uint cluster = linearizeDepth(cameraParams, depth) / depthStep;
        cluster = min(cluster, LIGHT_CLUSTER_DEPTH-1u);
#endif

        tileIdx = (tileX + frameData.lightIndicesParams.y * tileY + frameData.lightIndicesParams.z * cluster) * MAX_LIGHTS_PER_CLUSTER;
    }
    else {
        uint tileX = in.position.x / lightCullingTileSize;
        uint tileY = in.position.y / lightCullingTileSize;
        tileIdx = (tileX + frameData.lightIndicesParams.x * tileY) * MAX_LIGHTS_PER_TILE;
    }

    pointLightIndices += tileIdx;
    spotLightIndices += tileIdx;

    xhalf3 result = lightingShader(surfaceData,
                                   aoSample,
                                   depth,
                                   worldPosition,
                                   frameData,
                                   cameraParams,
                                   shadowMap,
                                   dfgLutTex,
                                   envMap,
                                   pointLightBuffer,
                                   spotLightBuffer,
                                   pointLightIndices,
                                   spotLightIndices,
#if USE_SPOT_LIGHT_SHADOWS
                                   spotShadowMaps,
#endif
                                   needDebugView);

#if USE_SCATTERING_VOLUME
    if(!needDebugView)
        result = applyScattering(result, uint2(in.position.xy), in.texCoord, depth, scattering, blueNoiseTexture, frameData, cameraParams);
#endif

    return xhalf4(result, 1);
}
