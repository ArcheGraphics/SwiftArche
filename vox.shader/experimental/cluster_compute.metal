//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "function_constant.h"
#include "cluster_compute.h"
#include "type_common.h"
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

//MARK: - Cluster Bounds
float3 lineIntersectionToZPlane(float3 a, float3 b, float zDistance) {
    float3 normal = float3(0.0, 0.0, 1.0);
    float3 ab = b - a;
    float3 t = (zDistance - dot(normal, a)) / dot(normal, ab);
    return a + t * ab;
}

float4 clipToView(matrix_float4x4 inverseMatrix, float4 clip) {
    float4 view = inverseMatrix * clip;
    return view / float4(view.w, view.w, view.w, view.w);
}

float4 screen2View(float4 projection, matrix_float4x4 inverseMatrix, float4 screen) {
    float2 texCoord = screen.xy / projection.xy;
    float4 clip = float4(float2(texCoord.x, 1.0 - texCoord.y) * 2.0 - float2(1.0, 1.0), screen.z, screen.w);
    return clipToView(inverseMatrix, clip);
}

constant float3 eyePos = float3(0.0, 0.0, 0.0);
kernel void cluster_bounds(constant float4& u_cluster_uniform [[buffer(0)]],
                           constant matrix_float4x4& u_projInvMat [[buffer(1)]],
                           device Clusters& u_clusters [[buffer(2)]],
                           uint3 global_id [[ thread_position_in_grid ]]) {
    uint32_t tileIndex = global_id.x +
    global_id.y * tileCount.x +
    global_id.z * tileCount.x * tileCount.y;
    
    float2 tileSize = float2(u_cluster_uniform.x / float(tileCount.x),
                             u_cluster_uniform.y / float(tileCount.y));
    
    float4 maxPoint_sS = float4(float2(float(global_id.x+1u), float(global_id.y+1u)) * tileSize, 0.0, 1.0);
    float4 minPoint_sS = float4(float2(float(global_id.x), float(global_id.y)) * tileSize, 0.0, 1.0);
    
    float3 maxPoint_vS = screen2View(u_cluster_uniform, u_projInvMat, maxPoint_sS).xyz;
    float3 minPoint_vS = screen2View(u_cluster_uniform, u_projInvMat, minPoint_sS).xyz;
    
    float tileNear = -u_cluster_uniform.z * pow(u_cluster_uniform.w/ u_cluster_uniform.z,
                                                float(global_id.z)/float(tileCount.z));
    float tileFar = -u_cluster_uniform.z * pow(u_cluster_uniform.w/ u_cluster_uniform.z,
                                               float(global_id.z+1u)/float(tileCount.z));
    
    float3 minPointNear = lineIntersectionToZPlane(eyePos, minPoint_vS, tileNear);
    float3 minPointFar = lineIntersectionToZPlane(eyePos, minPoint_vS, tileFar);
    float3 maxPointNear = lineIntersectionToZPlane(eyePos, maxPoint_vS, tileNear);
    float3 maxPointFar = lineIntersectionToZPlane(eyePos, maxPoint_vS, tileFar);
    
    u_clusters.bounds[tileIndex].minAABB = min(min(minPointNear, minPointFar),min(maxPointNear, maxPointFar));
    u_clusters.bounds[tileIndex].maxAABB = max(max(minPointNear, minPointFar),max(maxPointNear, maxPointFar));
}

//MARK: - Cluster Lights
float sqDistPointAABB(float3 point, float3 minAABB, float3 maxAABB) {
    float sqDist = 0.0;
    // const minAABB : vec3<f32> = clusters.bounds[tileIndex].minAABB;
    // const maxAABB : vec3<f32> = clusters.bounds[tileIndex].maxAABB;
    
    // Wait, does this actually work? Just porting code, but it seems suspect?
    for(int i = 0; i < 3; i = i + 1) {
        float v = point[i];
        if(v < minAABB[i]){
            sqDist = sqDist + (minAABB[i] - v) * (minAABB[i] - v);
        }
        if(v > maxAABB[i]){
            sqDist = sqDist + (v - maxAABB[i]) * (v - maxAABB[i]);
        }
    }
    
    return sqDist;
}

kernel void cluster_light(constant matrix_float4x4& u_projInvMat [[buffer(0)]],
                          constant matrix_float4x4& u_viewMat [[buffer(1)]],
                          device Clusters& u_clusters [[buffer(2)]],
                          device ClusterLightGroup& u_clusterLights [[buffer(3)]],
                          device PointLightData *u_pointLight [[buffer(4), function_constant(hasPointLight)]],
                          device SpotLightData *u_spotLight [[buffer(5), function_constant(hasSpotLight)]],
                          uint3 global_id [[ thread_position_in_grid ]]) {
    uint32_t tileIndex = global_id.x +
    global_id.y * tileCount.x +
    global_id.z * tileCount.x * tileCount.y;
    
    uint32_t clusterLightCount = 0u;
    array<uint32_t, 50> cluserLightIndices;
    if (hasPointLight) {
        for (uint32_t i = 0u; i < (uint32_t)pointLightCount; i = i + 1u) {
            float range = u_pointLight[i].distance;
            // Lights without an explicit range affect every cluster, but this is a poor way to handle that.
            bool lightInCluster = range <= 0.0;
            
            if (!lightInCluster) {
                float4 lightViewPos = u_viewMat * float4(u_pointLight[i].position, 1.0);
                float sqDist = sqDistPointAABB(lightViewPos.xyz, u_clusters.bounds[tileIndex].minAABB,
                                               u_clusters.bounds[tileIndex].maxAABB);
                lightInCluster = sqDist <= (range * range);
            }
            
            if (lightInCluster) {
                // Light affects this cluster. Add it to the list.
                cluserLightIndices[clusterLightCount] = i;
                clusterLightCount = clusterLightCount + 1u;
            }
            
            if (clusterLightCount == 50u) {
                break;
            }
        }
    }
    uint32_t pointLightCount = clusterLightCount;
    if (hasSpotLight) {
        for (uint32_t i = 0u; i < (uint32_t)spotLightCount; i = i + 1u) {
            float range = u_spotLight[i].distance;
            // Lights without an explicit range affect every cluster, but this is a poor way to handle that.
            bool lightInCluster = range <= 0.0;
            
            if (!lightInCluster) {
                float4 lightViewPos = u_viewMat * float4(u_spotLight[i].position, 1.0);
                float sqDist = sqDistPointAABB(lightViewPos.xyz, u_clusters.bounds[tileIndex].minAABB,
                                               u_clusters.bounds[tileIndex].maxAABB);
                lightInCluster = sqDist <= (range * range);
            }
            
            if (lightInCluster) {
                // Light affects this cluster. Add it to the list.
                cluserLightIndices[clusterLightCount] = i;
                clusterLightCount = clusterLightCount + 1u;
            }
            
            if (clusterLightCount == 50u) {
                break;
            }
        }
    }
    
    uint32_t offset = atomic_fetch_add_explicit(&u_clusterLights.offset, clusterLightCount,
                                                memory_order::memory_order_relaxed);
    
    for(uint32_t i = 0u; i < clusterLightCount; i = i + 1u) {
        u_clusterLights.indices[offset + i] = cluserLightIndices[i];
    }
    u_clusterLights.lights[tileIndex].offset = offset;
    u_clusterLights.lights[tileIndex].point_count = pointLightCount;
    u_clusterLights.lights[tileIndex].spot_count = clusterLightCount - pointLightCount;
    
}
