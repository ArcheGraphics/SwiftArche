//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void gravityForce(device float3* u_forces [[buffer(0)]],
                         constant float& mass [[buffer(1)]],
                         constant float3& gravity [[buffer(2)]],
                         device uint& u_count [[buffer(3)]],
                         uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x < u_count) {
        u_forces[tpig.x] = mass * gravity;
    }
}
