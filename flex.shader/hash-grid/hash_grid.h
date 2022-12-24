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
                               device const uint32_t* eit, device const float2* si, device const float4* p,
                               device const float4* o, Callback cb);
        
        template <typename Index>
        void operator()(Index idx);
        
    private:
        HashUtils _hashUtils;
        float _radius;
        device const uint32_t* _startIndexTable;
        device const uint32_t* _endIndexTable;
        device const float2* _sortedIndices;
        device const float4* _points;
        device const float4* _origins;
        Callback _callback;
    };
};
