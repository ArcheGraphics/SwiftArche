//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void initSortArgs(constant uint& g_NumElements [[buffer(1)]],
                         device MTLDispatchThreadgroupsIndirectArguments& args [[buffer(2)]]) {
    args.threadgroupsPerGrid[0] = ((g_NumElements - 1) >> 9) + 1;
    args.threadgroupsPerGrid[1] = 1;
    args.threadgroupsPerGrid[2] = 1;
}
