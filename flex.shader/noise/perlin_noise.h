//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "noise_common.h"

// MARK: - Perlin 2D
// Classic Perlin noise
float cnoise(float2 P);

// Classic Perlin noise, periodic variant
float pnoise(float2 P, float2 rep);

// MARK: - Perlin 3D
// Classic Perlin noise
float cnoise(float3 P);

// Classic Perlin noise, periodic variant
float pnoise(float3 P, float3 rep);

// MARK: - Perlin 4D
// Classic Perlin noise
float cnoise(float4 P);

// Classic Perlin noise, periodic version
float pnoise(float4 P, float4 rep);
