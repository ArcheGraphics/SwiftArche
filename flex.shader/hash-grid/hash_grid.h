//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;

class PointHashGridSearcher {
public:
    class HashUtils {
    public:
        HashUtils();
        
        HashUtils(float gridSpacing,
                  uint3 resolution);
        
        void getNearbyKeys(float3 position, thread uint32_t* nearbyKeys) const;
        
        int3 getBucketIndex(float3 position) const;
        
        uint32_t getHashKeyFromBucketIndex(int3 bucketIndex) const;
        
        uint32_t getHashKeyFromPosition(float3 position) const;
        
    private:
        float _gridSpacing;
        uint3 _resolution;
    };
    
    // MARK: - ForEachNearbyPointFunc
    template <typename Callback>
    class ForEachNearbyPointFunc {
    public:
        ForEachNearbyPointFunc(float r, float gridSpacing, uint3 resolution, device const uint32_t* sit,
                               device const uint32_t* eit, device const float2* si, device const float3* p,
                               device const float3* o, Callback cb)
        : _hashUtils(gridSpacing, resolution),
        _radius(r),
        _startIndexTable(sit),
        _endIndexTable(eit),
        _sortedIndices(si),
        _points(p),
        _origins(o),
        _callback(cb) {}
        
        template <typename Index>
        void operator()(Index idx) {
            const float3 origin = _origins[idx];
            
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
                
                for (uint32_t j = start; j < end; ++j) {
                    uint32_t index = _sortedIndices[j].y;
                    float3 p = _points[index];
                    float3 direction = p - origin;
                    float distanceSquared = length_squared(direction);
                    if (distanceSquared <= queryRadiusSquared) {
                        _callback(idx, origin, index, p);
                    }
                }
            }
        }
        
    private:
        HashUtils _hashUtils;
        float _radius;
        device const uint32_t* _startIndexTable;
        device const uint32_t* _endIndexTable;
        device const float2* _sortedIndices;
        device const float3* _points;
        device const float3* _origins;
        Callback _callback;
    };
};
