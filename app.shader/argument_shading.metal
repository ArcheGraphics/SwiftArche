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

vertex VertexOut vertex_argument_quad(uint v_id [[vertex_id]]) {
    VertexOut out;
    out.position = float4(offsets[v_id], 1.0);
    out.v_uv = offsets[v_id].xy;
    
    return out;
}

struct Material {
    sampler u_baseSampler [[id(0)]];
    texture2d<float> u_baseTexture [[id(1)]];
    float4 u_baseColor [[id(2)]];
};

fragment float4 fragment_argument_quad(VertexOut in [[stage_in]],
                                       constant Material& u_material [[buffer(3)]]) {
    return u_material.u_baseColor;
}
