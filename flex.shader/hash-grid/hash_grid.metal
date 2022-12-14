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


// MARK: - Builder
kernel void fillHashGrid(device uint* u_startIndexTable [[buffer(0)]],
                         device uint* u_endIndexTable [[buffer(1)]],
                         uint3 tpig [[ thread_position_in_grid ]]) {
    u_startIndexTable[tpig.x] = 0xffffffff;
    u_endIndexTable[tpig.x] = 0xffffffff;
}

kernel void initHashGridArgs(constant uint& g_NumElements [[buffer(2)]],
                             device MTLDispatchThreadgroupsIndirectArguments& args [[buffer(3)]]) {
    args.threadgroupsPerGrid[0] = ((g_NumElements - 1) >> 9) + 1;
    args.threadgroupsPerGrid[1] = 1;
    args.threadgroupsPerGrid[2] = 1;
}

kernel void prepareSortHash(device float2* u_sortedIndices [[buffer(4)]],
                            device float3* u_positions [[buffer(5)]],
                            constant HashGridData& u_hashGridData [[buffer(6)]],
                            constant uint& g_NumElements [[buffer(2)]],
                            uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x < g_NumElements) {
        PointHashGridSearcher::HashUtils hashUtils(u_hashGridData.gridSpacing,
                                                   uint3(u_hashGridData.resolutionX, u_hashGridData.resolutionY, u_hashGridData.resolutionZ));
        float2 sortedIndices = float2(hashUtils.getHashKeyFromPosition(u_positions[tpig.x]), tpig.x);
        u_sortedIndices[tpig.x] = sortedIndices;
    }
}

kernel void buildHashGrid(device uint* u_startIndexTable [[buffer(0)]],
                          device uint* u_endIndexTable [[buffer(1)]],
                          device float2* u_sortedIndices [[buffer(4)]],
                          constant uint& g_NumElements [[buffer(2)]],
                          uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x == 0) {
        u_startIndexTable[uint(u_sortedIndices[0].x)] = 0;
        u_endIndexTable[uint(u_sortedIndices[g_NumElements - 1].x)] = g_NumElements;
        return;
    }
    
    if (tpig.x > 1 && tpig.x < g_NumElements) {
        uint k = u_sortedIndices[tpig.x].x;
        uint kLeft = u_sortedIndices[tpig.x - 1].x;
        if (k > kLeft) {
            u_startIndexTable[k] = tpig.x;
            u_endIndexTable[kLeft] = tpig.x;
        }
    }
}
