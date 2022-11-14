//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <simd/simd.h>
#include <metal_stdlib>
using namespace metal;

class NormalShading {
public:
    NormalShading(matrix_float3x3 v_TBN);
    
    NormalShading(float3 v_pos, float2 v_uv, bool isFrontFacing);
    
    NormalShading(float3 v_pos, float2 v_uv);
    
    float3 getNormal();
    
    matrix_float3x3 getTBN();
    
    float3 getNormalByNormalTexture(matrix_float3x3 tbn, texture2d<float> normalTexture, sampler s,
                                    float normalIntensity, float2 uv);
    
private:
    matrix_float3x3 v_TBN;
    float3 v_normal;
    float3 v_pos;
    float2 v_uv;
    bool isFrontFacing;
};
