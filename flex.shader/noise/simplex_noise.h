//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include "noise_common.h"

float snoise(float2 v);

float snoise(float3 v);

float snoise(float3 v, thread float3& gradient);

float snoise(float4 v);
