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
                          constant SDFData& u_sdfData [[buffer(3), function_constant(hasSDF)]],
                          uint3 tpig [[ thread_position_in_grid ]],
                          uint3 gridSize [[ threads_per_grid ]]) {
    float3 wPos;
    wPos.x = tpig.x * u_emitterData.spacing + u_emitterData.lowerCorner.x;
    wPos.y = tpig.y * u_emitterData.spacing + u_emitterData.lowerCorner.y;
    wPos.z = tpig.z * u_emitterData.spacing + u_emitterData.lowerCorner.z;
    
    if (hasSDF) {
        auto uvw = (wPos - u_sdfData.SDFLower) / (u_sdfData.SDFUpper - u_sdfData.SDFLower);
        float sdf = u_sdfTexture.sample(u_sdfSampler, uvw).r;
        if (sdf < 0.0) {
            auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
            if (count < u_emitterData.maxNumberOfParticles) {
                u_position[count] = wPos;
            } else {
                atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
            }
        }\
    } else {
        auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
        if (count < u_emitterData.maxNumberOfParticles) {
            u_position[count] = wPos;
        } else {
            atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
        }
    }
}
