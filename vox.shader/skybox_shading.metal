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
} VertexIn;

typedef struct {
    float4 position [[position]];
    float3 v_cubeUV;
} VertexOut;

vertex VertexOut vertex_skybox(const VertexIn in [[stage_in]],
                               constant matrix_float4x4 &u_VPMat [[buffer(10)]]) {
    VertexOut out;
    
    out.v_cubeUV = in.POSITION.xyz;
    out.position = u_VPMat * float4(in.POSITION, 1.0);
    return out;
}

fragment float4 fragment_skybox(VertexOut in [[stage_in]],
                                sampler u_cubeSampler [[sampler(0)]],
                                texturecube<float> u_cubeTexture [[texture(0)]]) {
    return u_cubeTexture.sample(u_cubeSampler, in.v_cubeUV);    
}
