//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;

float taylorInvSqrt(float r);

float4 taylorInvSqrt(float4 r);

float mod289(float x);

float2 mod289(float2 x);

float3 mod289(float3 x);

float4 mod289(float4 x);

// Modulo 7 without a division
float3 mod7(float3 x);

float4 mod7(float4 x);

// Permutation polynomial: (34x^2 + 6x) mod 289
float3 permute(float3 x);

float4 permute(float4 x);

float permute(float x);
