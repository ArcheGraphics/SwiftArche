//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

#define SORT_SIZE     512
#define HALF_SIZE     (SORT_SIZE/2)
#define ITERATIONS    (HALF_SIZE > 1024 ? HALF_SIZE/1024 : 1)
#define NUM_THREADS   (HALF_SIZE/ITERATIONS)

kernel void preBitonicSort(constant uint& g_NumElements [[buffer(1)]],
                           device float2* Data [[buffer(2)]],
                           uint3 Gid [[threadgroup_position_in_grid]],
                           uint3 GTid [[thread_position_in_threadgroup]],
                           uint GI [[thread_index_in_threadgroup]]) {
    threadgroup float2 g_LDS[SORT_SIZE];
    
    int GlobalBaseIndex = (Gid.x * SORT_SIZE) + GTid.x;
    int LocalBaseIndex  = GI;
    
    uint numElementsInThreadGroup = min(uint(SORT_SIZE), uint(g_NumElements - (Gid.x * SORT_SIZE)));
    
    // Load shared data
    int i;
    for(i = 0; i < 2*ITERATIONS; ++i) {
        if(GI + i * NUM_THREADS < numElementsInThreadGroup) {
            g_LDS[LocalBaseIndex + i*NUM_THREADS] = Data[GlobalBaseIndex + i*NUM_THREADS];
        }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    
    // Bitonic sort
    for(unsigned int nMergeSize = 2; nMergeSize <= SORT_SIZE; nMergeSize = nMergeSize * 2) {
        for(int nMergeSubSize = nMergeSize >> 1; nMergeSubSize > 0; nMergeSubSize = nMergeSubSize >> 1) {
            for(i = 0; i < ITERATIONS; ++i) {
                int tmp_index = GI + NUM_THREADS * i;
                int index_low = tmp_index & (nMergeSubSize - 1);
                int index_high = 2 * (tmp_index - index_low);
                int index = index_high + index_low;
                
                unsigned int nSwapElem = nMergeSubSize == nMergeSize >> 1 ?
                index_high + (2 * nMergeSubSize - 1) - index_low : index_high + nMergeSubSize + index_low;
                if(nSwapElem < numElementsInThreadGroup) {
                    float2 a = g_LDS[index];
                    float2 b = g_LDS[nSwapElem];
                    
                    if(a.x > b.x) {
                        g_LDS[index] = b;
                        g_LDS[nSwapElem] = a;
                    }
                }
                threadgroup_barrier(mem_flags::mem_threadgroup);
            }
        }
    }
    
    for( i = 0; i < 2 * ITERATIONS; ++i) {
        if(GI + i * NUM_THREADS < numElementsInThreadGroup)
            Data[GlobalBaseIndex + i * NUM_THREADS] = g_LDS[LocalBaseIndex + i * NUM_THREADS];
    }
}

#undef SORT_SIZE
#undef HALF_SIZE
#undef ITERATIONS
#undef NUM_THREADS
