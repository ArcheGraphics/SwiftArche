//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "hash_grid.h"
#include "../type_common.h"

PointHashGridSearcher::HashUtils::HashUtils() {}

PointHashGridSearcher::HashUtils::HashUtils(float gridSpacing, uint3 resolution)
: _gridSpacing(gridSpacing), _resolution(resolution) {}

void PointHashGridSearcher::HashUtils::getNearbyKeys(float3 position, thread uint32_t* nearbyKeys) const {
    int3 originIndex = getBucketIndex(position), nearbyBucketIndices[8];
    
    for (int i = 0; i < 8; i++) {
        nearbyBucketIndices[i] = originIndex;
    }
    
    if ((originIndex.x + 0.5f) * _gridSpacing <= position.x) {
        nearbyBucketIndices[1].x += 1;
        nearbyBucketIndices[3].x += 1;
        nearbyBucketIndices[5].x += 1;
        nearbyBucketIndices[7].x += 1;
    } else {
        nearbyBucketIndices[1].x -= 1;
        nearbyBucketIndices[3].x -= 1;
        nearbyBucketIndices[5].x -= 1;
        nearbyBucketIndices[7].x -= 1;
    }
    
    if ((originIndex.y + 0.5f) * _gridSpacing <= position.y) {
        nearbyBucketIndices[2].y += 1;
        nearbyBucketIndices[3].y += 1;
        nearbyBucketIndices[6].y += 1;
        nearbyBucketIndices[7].y += 1;
    } else {
        nearbyBucketIndices[2].y -= 1;
        nearbyBucketIndices[3].y -= 1;
        nearbyBucketIndices[6].y -= 1;
        nearbyBucketIndices[7].y -= 1;
    }
    
    if ((originIndex.z + 0.5f) * _gridSpacing <= position.z) {
        nearbyBucketIndices[4].z += 1;
        nearbyBucketIndices[5].z += 1;
        nearbyBucketIndices[6].z += 1;
        nearbyBucketIndices[7].z += 1;
    } else {
        nearbyBucketIndices[4].z -= 1;
        nearbyBucketIndices[5].z -= 1;
        nearbyBucketIndices[6].z -= 1;
        nearbyBucketIndices[7].z -= 1;
    }
    
    for (int i = 0; i < 8; i++) {
        nearbyKeys[i] = getHashKeyFromBucketIndex(nearbyBucketIndices[i]);
    }
}

int3 PointHashGridSearcher::HashUtils::getBucketIndex(float3 position) const {
    int3 bucketIndex;
    bucketIndex.x = (int)floor(position.x / _gridSpacing);
    bucketIndex.y = (int)floor(position.y / _gridSpacing);
    bucketIndex.z = (int)floor(position.z / _gridSpacing);
    return bucketIndex;
}

uint32_t PointHashGridSearcher::HashUtils::getHashKeyFromBucketIndex(int3 bucketIndex) const {
    // Assumes _resolution is power of two
    bucketIndex.x = bucketIndex.x & (_resolution.x - 1);
    bucketIndex.y = bucketIndex.y & (_resolution.y - 1);
    bucketIndex.z = bucketIndex.z & (_resolution.z - 1);
    return bucketIndex.z * _resolution.y * _resolution.x +
    bucketIndex.y * _resolution.x + bucketIndex.x;
}

uint32_t PointHashGridSearcher::HashUtils::getHashKeyFromPosition(float3 position) const {
    int3 bucketIndex = getBucketIndex(position);
    return getHashKeyFromBucketIndex(bucketIndex);
}

// MARK: - ForEachNearbyPointFunc
template <typename Callback>
PointHashGridSearcher::ForEachNearbyPointFunc<
Callback>::ForEachNearbyPointFunc(float r, float gridSpacing,
                                  uint3 resolution, device const uint32_t* sit,
                                  device const uint32_t* eit, device const float2* si,
                                  device const float4* p, device const float4* o,
                                  Callback cb)
: _hashUtils(gridSpacing, resolution),
_radius(r),
_startIndexTable(sit),
_endIndexTable(eit),
_sortedIndices(si),
_points(p),
_origins(o),
_callback(cb) {}

template <typename Callback>
template <typename Index>
void PointHashGridSearcher::ForEachNearbyPointFunc<Callback>::operator()(Index idx) {
    const float4 origin = _origins[idx];
    
    uint32_t nearbyKeys[8];
    _hashUtils.getNearbyKeys(origin, nearbyKeys);
    
    const float queryRadiusSquared = _radius * _radius;
    
    for (int i = 0; i < 8; i++) {
        uint32_t nearbyKey = nearbyKeys[i];
        uint32_t start = _startIndexTable[nearbyKey];
        
        // Empty bucket -- continue to next bucket
        if (start == 0xffffffff) {
            continue;
        }
        
        uint32_t end = _endIndexTable[nearbyKey];
        
        for (uint32_t jj = start; jj < end; ++jj) {
            uint32_t j = _sortedIndices[jj];
            float4 p = _points[jj];
            float4 direction = p - origin;
            float distanceSquared = length_squared(direction);
            if (distanceSquared <= queryRadiusSquared) {
                float distance = 0.0f;
                if (distanceSquared > 0) {
                    distance = sqrt(distanceSquared);
                    direction /= distance;
                }
                
                _callback(idx, origin, j, p);
            }
        }
    }
}


// MARK: - Builder
kernel void initHashGridArgs(constant uint& g_NumElements [[buffer(1)]],
                             device MTLDispatchThreadgroupsIndirectArguments& args [[buffer(2)]]) {
    args.threadgroupsPerGrid[0] = ((g_NumElements - 1) >> 9) + 1;
    args.threadgroupsPerGrid[1] = 1;
    args.threadgroupsPerGrid[2] = 1;
}

kernel void fillHashGrid(device uint32_t* u_startIndexTable [[buffer(0)]],
                         device uint32_t* u_endIndexTable [[buffer(1)]],
                         uint3 tpig [[ thread_position_in_grid ]]) {
    u_startIndexTable[tpig.x] = 0xffffffff;
    u_endIndexTable[tpig.x] = 0xffffffff;
}

kernel void prepareSortHash(device float2* u_sortedIndices [[buffer(0)]],
                            device float3* u_positions [[buffer(1)]],
                            constant HashGridData& u_hashGridData [[buffer(2)]],
                            constant uint& g_NumElements [[buffer(3)]],
                            uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x < g_NumElements) {
        PointHashGridSearcher::HashUtils hashUtils(u_hashGridData.gridSpacing,
                                                   uint3(u_hashGridData.resolutionX, u_hashGridData.resolutionY, u_hashGridData.resolutionZ));
        float2 sortedIndices = float2(hashUtils.getHashKeyFromPosition(u_positions[tpig.x]), tpig.x);
        u_sortedIndices[tpig.x] = sortedIndices;
    }
}

kernel void buildHashGrid(device uint32_t* u_startIndexTable [[buffer(0)]],
                          device uint32_t* u_endIndexTable [[buffer(1)]],
                          device float2* u_sortedIndices [[buffer(2)]],
                          constant uint& g_NumElements [[buffer(3)]],
                          uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x == 0) {
        u_startIndexTable[uint32_t(u_sortedIndices[0].x)] = 0;
        u_endIndexTable[uint32_t(u_sortedIndices[g_NumElements - 1].x)] = g_NumElements;
        return;
    }
    
    if (tpig.x > 1 && tpig.x < g_NumElements) {
        uint32_t k = u_sortedIndices[tpig.x].x;
        uint32_t kLeft = u_sortedIndices[tpig.x - 1].x;
        if (k > kLeft) {
            u_startIndexTable[k] = tpig.x;
            u_endIndexTable[kLeft] = tpig.x;
        }
    }
}
