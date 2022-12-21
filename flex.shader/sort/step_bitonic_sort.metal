//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void stepBitonicSort(constant uint& g_NumElements [[buffer(1)]],
                            device float2* Data [[buffer(2)]],
                            constant int& nMergeSubSize [[buffer(3)]],
                            constant int& nMergeSubSizeHigh [[buffer(4)]],
                            constant int& nMergeSubSizeLow [[buffer(5)]],
                            uint3 Gid [[threadgroup_position_in_grid]],
                            uint3 GTid [[thread_position_in_threadgroup]]) {
    uint localID = Gid.x * 256 + GTid.x; // calculate threadID within this sortable-array
    
    uint index_low = localID & (nMergeSubSize - 1);
    uint index_high = 2 * (localID - index_low);
    
    uint index = index_high + index_low;
    uint nSwapElem = index_high + nMergeSubSizeHigh + nMergeSubSizeLow * index_low;
    
    if (nSwapElem < g_NumElements) {
        float2 a = Data[index];
        float2 b = Data[nSwapElem];
        
        if (a.x > b.x) {
            Data[index] = b;
            Data[nSwapElem] = a;
        }
    }
}
