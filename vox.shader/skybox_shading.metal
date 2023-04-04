//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "arguments.h"
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
    out.v_cubeUV = float3( -out.v_cubeUV.x, out.v_cubeUV.yz );// TextureCube is left-hand,so x need inverse
    out.position = u_VPMat * float4(in.POSITION, 1.0);
    return out;
}

float4 equirectangularSample(float3 direction, sampler s, texture2d<float> image) {
    float3 d = normalize(direction);
    float2 t = float2((atan2(d.z, d.x) + M_PI_F) / (2.f * M_PI_F), acos(d.y) / M_PI_F);
    return image.sample(s, t);
}

fragment float4 fragment_skybox(VertexOut in [[stage_in]],
                                sampler u_cubeSampler [[sampler(0)]],
                                texturecube<float> u_cubeTexture [[texture(0)]]) {
    return u_cubeTexture.sample(u_cubeSampler, in.v_cubeUV);
}

fragment float4 fragment_skyboxHDR(VertexOut in [[stage_in]],
                                   sampler u_cubeSampler [[sampler(0)]],
                                   texture2d<float> u_cubeTexture [[texture(0)]]) {
    float3 c = equirectangularSample(in.v_cubeUV, u_cubeSampler, u_cubeTexture).rgb;
    return float4(clamp(c, 0.f, 500.0), 1.f);
}
