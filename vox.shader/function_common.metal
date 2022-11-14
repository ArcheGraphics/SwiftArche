//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "function_common.h"

float pow2(float x) {
    return x * x;
}

float4 RGBMToLinear(float4 value, float maxRange) {
    return float4(value.rgb * value.a * maxRange, 1.0);
}

float4 gammaToLinear(float4 srgbIn) {
    return float4(pow(srgbIn.rgb, float3(2.2)), srgbIn.a);
}

float4 linearToGamma(float4 linearIn) {
    return float4(pow(linearIn.rgb, float3(1.0 / 2.2)), linearIn.a);
}

float4x4 getJointMatrix(texture2d<float> joint_tex,
                        float index, int u_jointCount) {
    float base = index / u_jointCount;
    float hf = 0.5 / u_jointCount;
    float v = base + hf;
    
    float4 m0 = joint_tex.read(ushort2(0.125 * joint_tex.get_width(), v));
    float4 m1 = joint_tex.read(ushort2(0.375 * joint_tex.get_width(), v));
    float4 m2 = joint_tex.read(ushort2(0.625 * joint_tex.get_width(), v));
    float4 m3 = joint_tex.read(ushort2(0.875 * joint_tex.get_width(), v));
    
    return float4x4(m0, m1, m2, m3);
}

float3 getBlendShapeVertexElement(int blendShapeIndex, int vertexElementIndex,
                                  int3 u_blendShapeTextureInfo,
                                  texture2d_array<float> u_blendShapeTexture) {
    int y = vertexElementIndex / u_blendShapeTextureInfo.y;
    int x = vertexElementIndex - y * u_blendShapeTextureInfo.y;
    return  u_blendShapeTexture.read(ushort2(x, y), blendShapeIndex).xyz;
}
