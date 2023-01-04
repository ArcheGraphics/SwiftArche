//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void semiImplicitEuler(device float3* u_position [[buffer(0)]],
                              device float3* u_velocity [[buffer(1)]],
                              device float3* u_force [[buffer(2)]],
                              constant float& dt [[buffer(3)]],
                              constant float& mass [[buffer(4)]],
                              device uint& u_counter [[buffer(5)]],
                              uint3 tpig [[ thread_position_in_grid ]]) {
    if (tpig.x < u_counter) {
        u_velocity[tpig.x] = u_velocity[tpig.x] + dt * u_force[tpig.x] / mass;
        u_position[tpig.x] = u_position[tpig.x] + dt * u_velocity[tpig.x];
    }
}
