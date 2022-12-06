//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "../vox.shader/cluster_compute.h"
using namespace metal;

float linearDepth(float4 projection, float depthSample) {
    return projection.w * projection.z / fma(depthSample, projection.z - projection.w, projection.w);
}

float3 getTile(float4 projection, float4 fragCoord) {
    // TODO: scale and bias calculation can be moved outside the shader to save cycles.
    float sliceScale = float(tileCount.z) / log2(projection.w / projection.z);
    float sliceBias = -(float(tileCount.z) * log2(projection.z) / log2(projection.w / projection.z));
    float zTile = uint32_t(max(log2(linearDepth(projection, fragCoord.z)) * sliceScale + sliceBias, 0.0));
    
    return float3(uint32_t(fragCoord.x / (projection.x / float(tileCount.x))),
                  uint32_t(fragCoord.y / (projection.y / float(tileCount.y))),
                  zTile);
}

uint32_t getClusterIndex(float4 projection, float4 fragCoord) {
    float3 tile = getTile(projection, fragCoord);
    return tile.x + tile.y * tileCount.x + tile.z * tileCount.x * tileCount.y;
}

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

fragment float4 fragment_cluster_debug(VertexOut in [[stage_in]],
                                       constant float4& u_cluster_uniform [[buffer(5)]],
                                       device ClusterLightGroup& u_clusterLights [[buffer(6)]]) {
    uint32_t clusterIndex = getClusterIndex(u_cluster_uniform, in.position);
    uint32_t lightCount = u_clusterLights.lights[clusterIndex].point_count + u_clusterLights.lights[clusterIndex].spot_count;
    float lightFactor = float(lightCount) / float(MAX_LIGHTS_PER_CLUSTER);
    
    return mix(float4(0.0, 0.0, 1.0, 1.0), float4(1.0, 0.0, 0.0, 1.0),
               float4(lightFactor, lightFactor, lightFactor, lightFactor));
}
