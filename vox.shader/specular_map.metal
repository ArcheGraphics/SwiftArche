//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "pbr_common.h"

kernel void build_specular(texturecube<float, access::sample> input [[ texture(0) ]],
                           texturecube<float, access::write> output [[ texture(1) ]],
                           constant float &roughness [[ buffer(0) ]],
                           uint3 tpig [[ thread_position_in_grid ]]) {
    float inputWidth = input.get_width();
    float width = output.get_width();
    float scale = inputWidth / width;
    uint face = tpig.z;
    constexpr sampler s(filter::linear);
    float2 inputuv = float2(tpig.xy) / inputWidth;
    float3 direction = convertUVToDirection(face, inputuv);
    
    float3 result = PrefilterEnvMap(roughness, direction, input);
    float4 color = input.sample(s, direction, level(roughness*10));
    color = float4(result, 1);
    uint2 outputuv = uint2(tpig.x/scale, tpig.y/scale);
    output.write(color, outputuv, face);
}
