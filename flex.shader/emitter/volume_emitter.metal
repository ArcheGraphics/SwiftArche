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

kernel void volumeEmitter(sampler u_sdfSampler [[sampler(0), function_constant(hasSDF)]],
                          texture3d<float> u_sdfTexture [[texture(0), function_constant(hasSDF)]],
                          sampler u_randomSampler [[sampler(1)]],
                          texture1d<float> u_randomTexture [[texture(1)]],
                          device float3* u_position [[buffer(0)]],
                          device float3* u_velocity [[buffer(1)]],
                          device atomic_uint* u_counter[[buffer(2)]],
                          constant VolumeParticleEmitterData& u_emitterData [[buffer(3)]],
                          constant SDFData& u_sdfData [[buffer(4), function_constant(hasSDF)]],
                          uint3 tpig [[ thread_position_in_grid ]],
                          uint3 gridSize [[ threads_per_grid ]]) {
    float3 wPos;
    wPos.x = tpig.x * u_emitterData.spacing + u_emitterData.lowerCorner.x;
    wPos.y = tpig.y * u_emitterData.spacing + u_emitterData.lowerCorner.y;
    wPos.z = tpig.z * u_emitterData.spacing + u_emitterData.lowerCorner.z;

    float maxJitterDist = 0.5 * u_emitterData.jitter * u_emitterData.spacing;
    
    float2 random = u_randomTexture.sample(u_randomSampler, float(tpig.x) / float(gridSize.x)).rg;
    float3 randomDir = uniformSampleSphere(random.x, random.y);
    float3 offset = maxJitterDist * randomDir;
    float3 candidate = wPos + offset;

    if (hasSDF) {
        auto uvw = (candidate - u_sdfData.SDFLower) / (u_sdfData.SDFUpper - u_sdfData.SDFLower);
        float sdf = u_sdfTexture.sample(u_sdfSampler, uvw).r;
        if (sdf < 0.0) {
            auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
            if (count < u_emitterData.maxNumberOfParticles) {
                u_position[count] = candidate;
                
                float3 r = candidate;
                u_velocity[count] = u_emitterData.linearVelocity + cross(u_emitterData.angularVelocity, r) + u_emitterData.initialVelocity;
            } else {
                atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
            }
        }
    } else {
        auto count = atomic_fetch_add_explicit(u_counter, 1, memory_order::memory_order_relaxed);
        if (count < u_emitterData.maxNumberOfParticles) {
            u_position[count] = candidate;
            
            float3 r = candidate;
            u_velocity[count] = u_emitterData.linearVelocity + cross(u_emitterData.angularVelocity, r) + u_emitterData.initialVelocity;
        } else {
            atomic_fetch_sub_explicit(u_counter, 1, memory_order::memory_order_relaxed);
        }
    }
}
