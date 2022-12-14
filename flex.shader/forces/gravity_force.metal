//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "../type_common.h"

kernel void gravityForce(device float3* u_force [[buffer(0)]],
                         constant ForceData& u_forceData [[buffer(1)]],
                         device uint& u_counter [[buffer(3)]],
                         uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x < u_counter) {
        u_force[tpig.x] = u_forceData.mass * u_forceData.gravity;
    }
}
