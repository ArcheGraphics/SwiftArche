//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "noise_common.h"

float taylorInvSqrt(float r) {
  return 1.79284291400159 - 0.85373472095314 * r;
}

float4 taylorInvSqrt(float4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 mod289(float3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289(float4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// Modulo 7 without a division
float3 mod7(float3 x) {
    return x - floor(x * (1.0 / 7.0)) * 7.0;
}

float4 mod7(float4 x) {
    return x - floor(x * (1.0 / 7.0)) * 7.0;
}

// Permutation polynomial: (34x^2 + 6x) mod 289
float3 permute(float3 x) {
    return mod289((34.0 * x + 10.0) * x);
}

float4 permute(float4 x) {
    return mod289((34.0 * x + 10.0) * x);
}

float permute(float x) {
     return mod289(((x*34.0)+10.0)*x);
}
