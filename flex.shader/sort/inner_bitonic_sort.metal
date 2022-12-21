//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

#define SORT_SIZE     512
#define NUM_THREADS   (SORT_SIZE/2)

kernel void innerBitonicSort(constant uint& g_NumElements [[buffer(1)]],
                             device float2* Data [[buffer(2)]],
                             uint3 Gid [[threadgroup_position_in_grid]],
                             uint3 GTid [[thread_position_in_threadgroup]],
                             uint GI [[thread_index_in_threadgroup]]) {
    threadgroup float2 g_LDS[SORT_SIZE];
    
    int tgpx = Gid.x * 256;
    int tgpw = min(512, max(0, int(g_NumElements - Gid.x * 512)));
    
    int GlobalBaseIndex = tgpx * 2 + GTid.x;
    int LocalBaseIndex  = GI;
    int i;
    
    // Load shared data
    for(i = 0; i < 2; ++i) {
        if (int(GI + i * NUM_THREADS) < tgpw) {
            g_LDS[LocalBaseIndex + i * NUM_THREADS] = Data[GlobalBaseIndex + i * NUM_THREADS];
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    
    // sort threadgroup shared memory
    for (int nMergeSubSize = SORT_SIZE >> 1; nMergeSubSize > 0; nMergeSubSize = nMergeSubSize >> 1){
        int tmp_index = GI;
        int index_low = tmp_index & (nMergeSubSize - 1);
        int index_high = 2 * (tmp_index - index_low);
        int index = index_high + index_low;

        unsigned int nSwapElem = index_high + nMergeSubSize + index_low;

        if (int(nSwapElem) < tgpw) {
            float2 a = g_LDS[index];
            float2 b = g_LDS[nSwapElem];

            if (a.x > b.x) {
                g_LDS[index] = b;
                g_LDS[nSwapElem] = a;
            }
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }
    
    // Store shared data
    for (i = 0; i < 2; ++i) {
        if (int(GI + i * NUM_THREADS) < tgpw) {
            Data[GlobalBaseIndex + i * NUM_THREADS] = g_LDS[LocalBaseIndex + i * NUM_THREADS];
        }
    }
}

#undef SORT_SIZE
#undef NUM_THREADS
