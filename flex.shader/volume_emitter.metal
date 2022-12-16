//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"
#include "function_constant.h"

kernel void volumeEmitter(sampler u_sdfSampler [[sampler(0), function_constant(hasSDF)]],
                          texture3d<float> u_sdfTexture [[texture(0), function_constant(hasSDF)]],
                          device float3* u_position [[buffer(0)]],
                          device atomic_uint* u_counter[[buffer(1)]],
                          constant VolumeParticleEmitterData& u_emitterData [[buffer(2)]],
                          uint3 tpig [[ thread_position_in_grid ]]) {
    auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
    if (count < u_emitterData.maxNumberOfParticles) {
        float3 position;
        position.z = (tpig.z + 0.5) * u_emitterData.spacing + u_emitterData.lowerCorner.z;
        position.y = (tpig.y + 0.5) * u_emitterData.spacing + u_emitterData.lowerCorner.y;
        position.x = (tpig.x + 0.5) * u_emitterData.spacing + u_emitterData.lowerCorner.x;
        u_position[count] = position;
    } else {
        atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
    }
}
