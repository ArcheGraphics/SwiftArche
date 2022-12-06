//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#ifndef cluster_compute_h
#define cluster_compute_h

#include <simd/simd.h>
#include <metal_stdlib>

constant uint32_t MAX_LIGHTS_PER_CLUSTER = 50;
constant uint3 tileCount = uint3(32, 18, 48);

struct ClusterBounds {
    float3 minAABB;
    float3 maxAABB;
};
struct Clusters {
    metal::array<ClusterBounds, 32 * 18 * 48> bounds; // TOTAL_TILES
};

struct ClusterLights {
    uint32_t offset;
    uint32_t point_count;
    uint32_t spot_count;
};
struct ClusterLightGroup {
    metal::atomic_uint offset;
    metal::array<ClusterLights, 32 * 18 * 48> lights; // TOTAL_TILES
    metal::array<uint32_t, 50 * 32 * 18 * 48> indices; // MAX_LIGHTS_PER_CLUSTER * TOTAL_TILES
};

float linearDepth(float4 projection, float depthSample);

float3 getTile(float4 projection, float4 fragCoord);

uint32_t getClusterIndex(float4 projection, float4 fragCoord);

#endif /* cluster_compute_h */
