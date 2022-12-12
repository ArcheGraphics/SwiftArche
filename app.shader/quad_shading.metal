//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
#include "type_common.h"
using namespace metal;

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

constant float3 offsets[6] = {
    float3(-1, 1, 0),
    float3(-1, -1, 0),
    float3(1, 1, 0),
    float3(1, -1, 0),
    float3(1, 1, 0),
    float3(-1, -1, 0)
};

vertex VertexOut vertex_quad(uint v_id [[vertex_id]]) {
    VertexOut out;
    out.position = float4(offsets[v_id], 1.0);
    out.v_uv = offsets[v_id].xy;
    
    return out;
}

fragment float4 fragment_quad(VertexOut in [[stage_in]],
                              sampler u_baseSampler [[sampler(0)]],
                              texture2d<float> u_baseTexture [[texture(0)]]) {
    return u_baseTexture.sample(u_baseSampler, in.v_uv * 0.5 + 0.5);
}
