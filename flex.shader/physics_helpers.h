//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#pragma once

#include <metal_stdlib>
using namespace metal;

float2 ComputeDragForce(float dragCoefficient, float radius, float2 velocity);

float3 ComputeDragForce(float dragCoefficient, float radius, float3 velocity);
