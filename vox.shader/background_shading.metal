//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"
#include "function_constant.h"
#include "function_common.h"

typedef struct {
    float3 POSITION [[attribute(Position)]];
    float2 TEXCOORD_0 [[attribute(UV_0), function_constant(hasUV)]];
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 v_uv;
} VertexOut;

vertex VertexOut vertex_background(const VertexIn in [[stage_in]]) {
    VertexOut out;
    
    out.v_uv = in.TEXCOORD_0;
    out.position = float4(in.POSITION, 1.0);
    return out;
}

fragment float4 fragment_background(VertexOut in [[stage_in]],
                                sampler u_baseSampler [[sampler(0)]],
                                texture2d<float> u_baseTexture [[texture(0)]]) {
    return u_baseTexture.sample(u_baseSampler, in.v_uv);
}
