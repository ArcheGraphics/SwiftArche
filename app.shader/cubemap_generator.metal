//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

float4 equirectangularSample(float3 direction, sampler s, texture2d<float> image) {
    float3 d = normalize(direction);
    float2 t = float2((atan2(d.z, d.x) + M_PI_F) / (2.f * M_PI_F), acos(d.y) / M_PI_F);
    return image.sample(s, t);
}

kernel void cubemap_generator(texture2d<float, access::sample> hdr [[ texture(0) ]],
                              texturecube<float, access::write> output [[ texture(1) ]],
                              uint3 tpig [[ thread_position_in_grid ]]) {
    uint face = tpig.z;
    float2 inputuv = float2(tpig.xy) / output.get_width();

    float u = 2.0 * inputuv.x - 1.0;
    float v = -2.0 * inputuv.y + 1.0;

    float3 direction;
    switch(face) {
        case 0:
            direction = float3(1.0, v, -u);
            break;
        case 1:
            direction = float3(-1.0, v, u);
            break;
        case 2:
            direction = float3(u, 1.0, -v);
            break;
        case 3:
            direction = float3(u, -1.0, v);
            break;
        case 4:
            direction = float3(u, v, 1.0);
            break;
        case 5:
            direction = float3(-u, v, -1.0);
            break;
    }
    direction = normalize(direction);
    constexpr sampler linearFilterSampler(coord::normalized, address::clamp_to_edge, mip_filter::linear, filter::linear);
    float4 color = equirectangularSample(direction, linearFilterSampler, hdr);
    
    output.write(float4(clamp(color.rgb, 0.f, 500), 1.f), tpig.xy, face);
}
