//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "../function_common.h"
#include "../function_constant.h"
#include "../shader_common.h"

// Checks if a pixel is on the border of a tile.
static bool isBorder(uint2 xy, uint tileSize) {
    uint pixel_in_tile_x = (uint)xy.x % tileSize;
    uint pixel_in_tile_y = (uint)xy.y % tileSize;
    return ((pixel_in_tile_x == 0)
            | (pixel_in_tile_y == 0)
            | (pixel_in_tile_x == tileSize-1)
            | (pixel_in_tile_y == tileSize-1));
}

#define DEBUG_MAX_LIGHTS (12)

// Fragment shader to render a heatmap color based on the light count for the tile.
fragment float4 fragmentLightHeatmapShader(SimpleVertexOut in [[stage_in]],
                                           device uint8_t *pointLightIndices [[buffer(0)]],
                                           device uint8_t *spotLightIndices [[buffer(1)]],
                                           device uint8_t *pointLightTransparentIndices [[buffer(2)]],
                                           device uint8_t *spotLightTransparentIndices [[buffer(3)]],
                                           constant float4 &params [[buffer(4)]],
                                           constant rasterization_rate_map_data * rrData [[buffer(5), function_constant(needRasterizationRate)]],
                                           device FrameConstants & frameData  [[buffer(6)]]) {
    uint2 screenPos = uint2(in.position.xy);
#if SUPPORT_RASTERIZATION_RATE
    if (needRasterizationRate)
    {
        // This heat map is composited after restoring original screen space.
        // We convert back to physical space to find the original light tile.
        rasterization_rate_map_decoder decoder(*rrData);
        screenPos = decoder.map_screen_to_physical_coordinates(screenPos);
    }
#endif

    uint tile_x = screenPos.x / lightCullingTileSize;
    uint tile_y = screenPos.y / lightCullingTileSize;

    uint tileIdx = (tile_x + params.x * tile_y) * MAX_LIGHTS_PER_TILE;

    uint32_t pointLightCount = pointLightIndices[tileIdx];
    uint32_t spotLightCount = spotLightIndices[tileIdx];
    uint32_t lightCount = pointLightCount + spotLightCount;

    uint32_t pointLightTransparentCount = pointLightTransparentIndices[tileIdx];
    uint32_t spotLightTransparentCount = spotLightTransparentIndices[tileIdx];
    uint32_t lightTransparentCount = pointLightTransparentCount + spotLightTransparentCount;

    float blendTransparentStrength = params.z;

    float4 heatmap              = getHeatmapColor(lightCount, DEBUG_MAX_LIGHTS);
    float4 heatmapTransparent   = getHeatmapColor(lightTransparentCount, DEBUG_MAX_LIGHTS);

    float4 result = mix(heatmap, heatmapTransparent, blendTransparentStrength);
    if(isBorder(screenPos, lightCullingTileSize))
        result.w *= 0.25f;
    return result;
}

fragment float4 fragmentLightClusterHeatmapShader(SimpleTexVertexOut in [[stage_in]],
                                                  device uint8_t *pointLightIndices [[buffer(0)]],
                                                  device uint8_t *spotLightIndices [[buffer(1)]],
                                                  constant float4 &params [[buffer(2)]],
                                                  constant CameraData & cameraParams [[buffer(3)]],
                                                  constant rasterization_rate_map_data * rrData [[buffer(4), function_constant(needRasterizationRate)]],
                                                  depth2d<float, access::sample> inDepth [[texture(0)]])
{
    uint2 screenPos = uint2(in.position.xy);
#if SUPPORT_RASTERIZATION_RATE
    if (needRasterizationRate) {
        // This heat map is composited after restoring original screen space.
        // We convert back to physical space to find the original light tile.
        rasterization_rate_map_decoder decoder(*rrData);
        screenPos = decoder.map_screen_to_physical_coordinates(screenPos);
    }
#endif

    uint tile_x = screenPos.x / lightCullingTileSize;
    uint tile_y = screenPos.y / lightCullingTileSize;

    constexpr sampler nearestSampler(mip_filter::nearest, mag_filter::nearest, min_filter::nearest, address::clamp_to_edge);
    const float depth = inDepth.sample(nearestSampler, in.texCoord);
    float linearDepth = linearizeDepth(cameraParams, depth);

#if LOCAL_LIGHT_SCATTERING
    uint zcluster = zToScatterDepth(linearDepth) * LIGHT_CLUSTER_DEPTH;
#else
    float depthStep = LIGHT_CLUSTER_RANGE / LIGHT_CLUSTER_DEPTH;
    uint zcluster = linearDepth / depthStep;
#endif

    uint tileIdx = (tile_x + params.x * tile_y + zcluster * params.y) * MAX_LIGHTS_PER_CLUSTER;

    uint32_t pointLightCount = pointLightIndices[tileIdx];
    uint32_t spotLightCount = spotLightIndices[tileIdx];
    uint32_t lightCount = pointLightCount + spotLightCount;

    uint32_t lightTransparentCount = pointLightCount + spotLightCount;

    for(int i = 0; i < LIGHT_CLUSTER_DEPTH; ++i) {
        uint tileIdx = (tile_x + params.x * tile_y + i * params.y) * MAX_LIGHTS_PER_CLUSTER;

        uint32_t pointLightCount = pointLightIndices[tileIdx];
        uint32_t spotLightCount = spotLightIndices[tileIdx];
        lightTransparentCount = max(lightTransparentCount, pointLightCount + spotLightCount);
    }

    float blendTransparentStrength = params.z;

    float4 heatmap              = getHeatmapColor(lightCount, DEBUG_MAX_LIGHTS);
    float4 heatmapTransparent   = getHeatmapColor(lightTransparentCount, DEBUG_MAX_LIGHTS);

    float4 result = mix(heatmap, heatmapTransparent, blendTransparentStrength);

    if(isBorder(screenPos, lightClusteringTileSize))
        result.w *= 0.25f;

    return result;
}
