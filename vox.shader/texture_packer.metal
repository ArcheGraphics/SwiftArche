//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void build_metallicRoughness(texture2d<float, access::sample> metallic [[ texture(0) ]],
                                    texture2d<float, access::sample> roughness [[ texture(1) ]],
                                    texture2d<float, access::write> output [[ texture(2) ]],
                                    uint3 tpig [[ thread_position_in_grid ]]) {
    float inputWidth = metallic.get_width();
    float width = output.get_width();
    float scale = inputWidth / width;
    constexpr sampler s(filter::linear);
    float2 inputuv = float2(tpig.xy) / inputWidth;
    
    float metal = metallic.sample(s, inputuv).x;
    float rough = roughness.sample(s, inputuv).x;

    uint2 outputuv = uint2(tpig.x/scale, tpig.y/scale);
    output.write(float4(0, rough, metal, 1.0), outputuv);
}
