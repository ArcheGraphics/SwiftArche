//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#import "LightingCommon.h"
#import "ShaderCommon.h"

//------------------------------------------------------------------------------

// Toggled to enable debug rendering to reduce the cost of the default shading
//  by not caching values for possible debug output.
constant bool gEnableDebugView         [[function_constant(XFunctionConstIndexDebugView)]];

constant bool gUseLightCluster         [[function_constant(XFunctionConstIndexLightCluster)]];

constant bool gUseRasterizationRate    [[function_constant(XFunctionConstIndexRasterizationRate)]];

constant uint gLightCullingTileSize    [[function_constant(XFunctionConstIndexLightCullingTileSize)]];

constant uint gLightClusteringTileSize [[function_constant(XFunctionConstIndexLightClusteringTileSize)]];

constant bool gUseSinglePassDeferred   [[function_constant(XFunctionConstIndexSinglePassDeferred)]];

constant bool gUseTraditionalDeferred = !gUseSinglePassDeferred;

//------------------------------------------------------------------------------

// Performs tiled lighting, reading the GBuffer from either tile memory or
//  output textures.
// Executes after FSQuadVertexShader so that it renders as a full screen pass
//  with an input texcoord in screen space.
fragment xhalf4 tiledLightingShader(XSimpleTexVertexOut in                      [[ stage_in ]],
                                    constant XFrameConstants & frameData        [[ buffer(XBufferIndexFrameData) ]],
                                    constant XCameraParams & cameraParams       [[ buffer(XBufferIndexCameraParams) ]],
                                    constant rasterization_rate_map_data * rrData  [[ buffer(XBufferIndexRasterizationRateMap), function_constant(gUseRasterizationRate) ]],
                                    constant XPointLightData * pointLightBuffer [[ buffer(XBufferIndexPointLights) ]],
                                    constant XSpotLightData * spotLightBuffer   [[ buffer(XBufferIndexSpotLights) ]],
                                    constant uint8_t * pointLightIndices           [[ buffer(XBufferIndexPointLightIndices) ]],
                                    constant uint8_t * spotLightIndices            [[ buffer(XBufferIndexSpotLightIndices) ]],
                                    xhalf4 albedoTarget      [[color(XGBufferAlbedoAlphaIndex), function_constant(gUseSinglePassDeferred)]],
                                    xhalf4 normalTarget      [[color(XGBufferNormalsIndex), function_constant(gUseSinglePassDeferred)]],
                                    xhalf4 emissiveTarget    [[color(XGBufferEmissiveIndex), function_constant(gUseSinglePassDeferred)]],
                                    xhalf4 F0RoughnessTarget [[color(XGBufferF0RoughnessIndex), function_constant(gUseSinglePassDeferred)]],
                                    texture2d<xhalf, access::sample> albedoeTex     [[texture(0), function_constant(gUseTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> normalTex      [[texture(1), function_constant(gUseTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> emissiveTex    [[texture(2), function_constant(gUseTraditionalDeferred)]],
                                    texture2d<xhalf, access::sample> F0RoughnessTex [[texture(3), function_constant(gUseTraditionalDeferred)]],
                                    depth2d<float, access::sample>   inDepth        [[texture(4)]],
                                    depth2d_array<float, access::sample> shadowMap  [[texture (5)]],
#if USE_SCATTERING_VOLUME
                                    texture3d<xhalf, access::sample> scattering     [[texture(6)]],
#endif
                                    texture2d<xhalf, access::sample> dfgLutTex      [[texture(7)]],
                                    texturecube<xhalf, access::sample> envMap       [[texture(8)]],
#if USE_SCALABLE_AMBIENT_OBSCURANCE
                                    texture2d<xhalf, access::sample> saoTexture     [[texture(9)]],
#endif
#if USE_SPOT_LIGHT_SHADOWS
                                    depth2d_array<float, access::sample> spotShadowMaps [[texture(10)]],
#endif
                                    texture2d<float, access::read> blueNoiseTexture     [[texture(11)]]
                                    )
{
    constexpr sampler nearestSampler(mip_filter::nearest, mag_filter::nearest, min_filter::nearest, address::clamp_to_edge);

    float2 physicalCoord = in.texCoord;
#if SUPPORT_RASTERIZATION_RATE
    if (gUseRasterizationRate)
    {
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

    if(gUseSinglePassDeferred)
    {
        albedoSample = albedoTarget;
        normalSample = normalTarget;
        emissiveSample = emissiveTarget;
        F0RoughnessSample = F0RoughnessTarget;
    }
    else
    {
        albedoSample = albedoeTex.sample(nearestSampler, physicalCoord);
        normalSample = normalTex.sample(nearestSampler, physicalCoord);
        emissiveSample = emissiveTex.sample(nearestSampler, physicalCoord);
        F0RoughnessSample = F0RoughnessTex.sample(nearestSampler, physicalCoord);
    }

    XPixelSurfaceData surfaceData;
    surfaceData.normal      = (xhalf3)normalize((float3)normalSample.xyz); // normalizing half3 normal causes banding
    surfaceData.albedo      = albedoSample.xyz;
    surfaceData.F0          = mix(F0RoughnessSample.xyz, (xhalf)0.02, (xhalf)frameData.wetness);
    surfaceData.roughness   = mix(F0RoughnessSample.w, (xhalf)0.1, (xhalf)frameData.wetness);
    surfaceData.alpha       = 1.0f;
    surfaceData.emissive    = emissiveSample.rgb;

    const float depth = inDepth.sample(nearestSampler, physicalCoord);
    float4 worldPosition = worldPositionForTexcoord(in.texCoord, depth, cameraParams);

    uint tileIdx;
    if (gUseLightCluster)
    {
        uint tileX = in.position.x / gLightClusteringTileSize;
        uint tileY = in.position.y / gLightClusteringTileSize;

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
    else
    {
        uint tileX = in.position.x / gLightCullingTileSize;
        uint tileY = in.position.y / gLightCullingTileSize;
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
                                   gEnableDebugView);

#if USE_SCATTERING_VOLUME
    if(!gEnableDebugView)
        result = applyScattering(result, uint2(in.position.xy), in.texCoord, depth, scattering, blueNoiseTexture, frameData, cameraParams);
#endif

    return xhalf4(result, 1);
}
