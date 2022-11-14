//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "function_common.h"

float4x4 getJointMatrix(sampler smp, texture2d<float> joint_tex,
                        float index, int u_jointCount) {
    float base = index / u_jointCount;
    float hf = 0.5 / u_jointCount;
    float v = base + hf;
    
    float4 m0 = joint_tex.sample(smp, float2(0.125, v));
    float4 m1 = joint_tex.sample(smp, float2(0.375, v));
    float4 m2 = joint_tex.sample(smp, float2(0.625, v));
    float4 m3 = joint_tex.sample(smp, float2(0.875, v));
    
    return float4x4(m0, m1, m2, m3);
}
