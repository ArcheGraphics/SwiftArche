//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "../type_common.h"
#include "../function_constant.h"
#include "samplers.h"

kernel void pointEmitter(device float3* u_position [[buffer(0)]],
                         device float3* u_velocity [[buffer(1)]],
                         device atomic_uint* u_counter[[buffer(2)]],
                         constant PointParticleEmitterData& u_emitterData [[buffer(3)]],
                         sampler u_randomSampler [[sampler(0)]],
                         texture1d<float> u_randomTexture [[texture(0)]],
                         uint3 tpig [[ thread_position_in_grid ]],
                         uint3 gridSize [[ threads_per_grid ]]) {
    float2 random = u_randomTexture.sample(u_randomSampler, float(tpig.x) / float(gridSize.x)).rg;
    float3 newDirection = uniformSampleCone(random.x, random.y, u_emitterData.direction, u_emitterData.spreadAngleInRadians);
    auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
    if (count < u_emitterData.maxNumberOfParticles) {
        u_position[count] = u_emitterData.origin;
        u_velocity[count] = u_emitterData.speed * newDirection;
    } else {
        atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
    }
}
